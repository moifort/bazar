# Migration System

Forward-only, sequential Firestore migrations. Meta is tracked in the Firestore collection
`migration-meta`, document `state`. Migrations are triggered on demand by `POST /admin/migrate`
(during provisioning / CI deploy) — there is **no** boot-time plugin and nothing calls
`process.exit`.

Location: `server/system/migration/`.

```
server/system/migration/
├── types.ts              # Migration, MigrationContext, MigrationResult, MigrationMeta
├── primitives.ts         # MigrationVersion / MigrationName constructors
├── runner.ts             # runMigrations(migrations)
└── migrations/
    ├── index.ts          # export const migrations: Migration[] = [...]
    └── NNNN-name.ts      # individual migrations
```

## When to migrate

The rule is
[here](./ddd-best-practices.md#migrations-are-forward-only-and-owned-by-a-runner): migrate when a
field is renamed, restructured or removed, or when an enum value changes meaning. Adding an
`ItemCategory` value is *additive* — no migration. Don't migrate for a new optional field, a new
collection, or a change in query logic or routes.

**Dropping `null` in favour of an absent field is a migration.** The domain models absence as a
missing key, but a document written earlier still carries `storageId: null`, and reading it back
puts `null` behind a type that says it cannot be there.

## Types

```ts
export type MigrationVersion = Brand<number, 'MigrationVersion'>
export type MigrationName = Brand<string, 'MigrationName'>

export type MigrationContext = { db: Firestore }

export type Migration = {
  version: MigrationVersion
  name: MigrationName
  migrate: (ctx: MigrationContext) => Promise<MigrationResult>
}

export type MigrationResult = { ok: true; transformed: number } | { ok: false; error: string }
```

The context hands you the native Firestore `db` directly — a migration reads and writes
collections itself (it is infrastructure, not a domain, so it bypasses repositories).

## Creating a migration

### 1. Create the file

`server/system/migration/migrations/0002-rename-foo-to-bar.ts`:

```ts
import { FieldValue } from 'firebase-admin/firestore'
import { MigrationName, MigrationVersion } from '~/system/migration/primitives'
import type { Migration } from '~/system/migration/types'

export const migration0002: Migration = {
  version: MigrationVersion(2),
  name: MigrationName('rename-foo-to-bar'),
  migrate: async ({ db }) => {
    const snap = await db.collection('items').get()
    let transformed = 0
    for (const doc of snap.docs) {
      const data = doc.data()
      if ('foo' in data) {
        await doc.ref.update({ bar: data.foo, foo: FieldValue.delete() })
        transformed++
      }
    }
    return { ok: true, transformed }
  },
}
```

The runner wraps each migration in try/catch, so a migration needs no error handling of its own —
throwing (or returning `{ ok: false, error }`) marks it failed and stops the run.

### 2. Register it

`server/system/migration/migrations/index.ts`, in ascending order:

```ts
export const migrations: Migration[] = [migration0001, migration0002]
```

## How it works (`runner.ts`)

1. `runMigrations(migrations)` reads `migration-meta/state`; absent → version `0` (the reserved
   sentinel — real migrations start at `1`).
2. It filters `version > current`, sorts ascending, and applies each in turn.
3. After each success it writes back `{ version, appliedAt }` and logs one line through
   `system/logger.ts`.
4. On a failed or throwing migration it returns `{ outcome: 'failed', version, error }` and stops.
5. It returns `{ outcome: 'up-to-date' }`, `{ outcome: 'migrated', from, to, applied }`, or the
   failure shape.

## Testing a migration

Co-locate an integration test `NNNN-name.int.test.ts` next to the migration: seed the
pre-migration documents into the in-memory fake, run `migrate`, assert the transformed shape.

```ts
import { expect, test } from 'bun:test'
import { resetFakeFirestore } from '~/test/fake-firestore'

const { migration0001 } = await import('./0001-absent-over-null')

test('drops null fields', async () => {
  const fake = resetFakeFirestore()
  fake.seed('items', 'i1', { id: 'i1', storageId: null, zoneId: 'z1' })

  const result = await migration0001.migrate({ db: fake.db })

  expect(result).toEqual({ ok: true, transformed: 1 })
  expect(fake.snapshot('items').get('i1')).toEqual({ id: 'i1', zoneId: 'z1' })
})
```

A migration without its test does not ship: it is the only thing that proves the transform on the
*old* shape, which by definition no longer exists in the code.

## Trigger — `POST /admin/migrate`

`server/routes/admin/migrate.post.ts` runs the migrations and sets **HTTP 500** on failure, so the
CI step gating on `curl -fsS` fails the deploy:

```ts
export default defineEventHandler(async (event) => {
  const result = await runMigrations(migrations)
  if (result.outcome === 'failed') setResponseStatus(event, 500)
  return result
})
```

The `/admin/*` routes are gated by the admin bearer token (`middleware/auth.ts`, `adminToken`),
**not** a Firebase user. The GitHub Actions deploy calls this endpoint after `terraform apply`.

## Rules

- `MigrationVersion` is a branded integer (`min 0`, string-coercible); `0` is the reserved
  sentinel, versions start at `1`.
- Migrations are **forward-only** — no rollback mechanism, so no rollback path to test and rot.
- The runner owns error handling; migrations stay focused on the transform.
- **Never run migrations locally against production data** — they run through `POST /admin/migrate`
  during provisioning / deploy.
- **Firestore rejects `undefined` values**: to remove a field, use `FieldValue.delete()`; to skip
  one, don't write the key at all.
