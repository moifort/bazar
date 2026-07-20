# Adding a New Domain

How a bounded context is built **in this repo**. The rules behind each step — what a repository
is allowed to do, why a command returns a sentinel, why business rules are pure — are in
[ddd-best-practices.md](./ddd-best-practices.md); where everything sits is in
[architecture.md](./architecture.md). This is the recipe, in order, with Bazar's own code as the
reference.

The reference domain is `item`: it persists, it orchestrates, it publishes events, and it owns a
GraphQL slice. Read it before writing a new one.

## Ubiquitous Language

One business concept = **one word**, at every layer — domain, GraphQL schema, iOS app, tests.
Bazar's vocabulary:

| Word | Meaning |
|------|---------|
| **item** | A physical object the user owns. Never "object", "thing" or "product". |
| **place / room / zone / storage** | The four levels of the location hierarchy, in that order. A *place* is a building, a *room* a room in it, a *zone* an area of that room, a *storage* the furniture the item sits in. |
| **attach / move** | Binding an item to a storage or a zone; `move` changes an existing attachment. Never "assign", "link". |
| **scan** | A photo analysed by the AI. It produces **previews**, which the user **confirms** into items. |
| **reminder** | A dated maintenance task attached to an item. Completing it either **reschedules** it (recurring) or **finishes** it (one-shot). |
| **low stock** | An item whose quantity has fallen to or below its `lowStockThreshold`. The moment it happens is a **crossing**. |

Renaming a concept renames it everywhere, in the same task. A half-renamed vocabulary is worse
than the old name.

## 1. Create the domain directory

```
server/domain/{domain}/
├── types.ts
├── primitives.ts
├── query.ts
├── command.ts                  # only if the domain writes
├── business-rules.ts           # optional — pure functions
├── use-case.ts                 # optional — multi-domain orchestration
├── events.ts                   # optional — published event shapes
└── infrastructure/
    ├── repository.ts           # only if the domain persists
    └── graphql/
        ├── enums.ts
        ├── types.ts
        ├── inputs.ts
        ├── queries.ts
        └── mutations.ts
```

`types.ts` is mandatory — the arch test asserts it for every folder under `server/domain/`.
A read-only domain (`search`, `dashboard`) has no `command.ts` and no repository.

## 2. Define types (`types.ts`)

Branded types via `ts-brand`, plus the domain shapes. **No Zod here, no IO, no functions.**
Absence is a **missing field**, never `null`:

```ts
import type { Brand } from 'ts-brand'
import type { StorageId, ZoneId } from '~/domain/location/types'
import type { UserId } from '~/domain/shared/types'

export type ItemId = Brand<string, 'ItemId'>
export type ItemName = Brand<string, 'ItemName'>
export type Quantity = Brand<number, 'Quantity'>

export type ItemCategory = 'tools' | 'appliances' | /* … */ 'other'

export type Item = {
  id: ItemId
  userId: UserId
  name: ItemName
  quantity: Quantity
  storageId?: StorageId       // absent when the item is attached to a zone, or nowhere
  zoneId?: ZoneId             // never set together with storageId
  createdAt: Date
}
```

A union of string literals beats an enum: it is the wire format, the Firestore value and the
GraphQL enum's backing value all at once. Values are English technical symbols
(`'custom-days'`), never display copy — see [code-style.md](./code-style.md).

## 3. Create the primitives (`primitives.ts`)

One Zod constructor per branded type: parse, then brand. If it parses, it is valid everywhere
downstream — nothing re-validates internally. The file must import both `ts-brand` and `zod`
(the arch test checks it).

```ts
import { make } from 'ts-brand'
import { z } from 'zod'
import type { ItemId as ItemIdType, ItemName as ItemNameType } from './types'

export const ItemId = (value: string) => make<ItemIdType>()(z.uuid().parse(value))
export const ItemName = (value: string) =>
  make<ItemNameType>()(z.string().trim().min(1).max(120).parse(value))
```

These constructors are what the GraphQL scalars call at the boundary
([graphql-patterns.md](./graphql-patterns.md#branded-scalars)), which is why commands take
**already-branded** arguments and never cast (`id as ItemId` is a bug, not a shortcut).

## 4. Create the repository (`infrastructure/repository.ts`)

The only place `db()` appears. Owner-scoped, converter-wrapped, and it does the filtering,
sorting and pagination itself:

```ts
const items = () => db().collection('items').withConverter(genericDataConverter<Item>())

export const findAllByUser = memoizedPerRequest('item.findAllByUser', async (userId: UserId) => {
  const snap = await items().where('userId', '==', userId).orderBy('createdAt', 'desc').get()
  return snap.docs.map((doc) => doc.data())
})

export const findBy = async (userId: UserId, id: ItemId) => {
  const data = (await items().doc(id).get()).data()
  return data?.userId === userId ? data : undefined
}
```

Rules that bite here:

- **`findAll` / `findBy` naming survives only in the repository** — it is the repository idiom.
- **Every query filters on `userId`.** A document read by id is checked for ownership before
  being returned, and returns `undefined` (not `null`) when missing or foreign.
- **Repeated reads in one request** go through `memoizedPerRequest`.
- **Multi-document writes are atomic** — one `WriteBatch` committed once.
- Firestore drops documents missing the `orderBy` field: only sort on always-present fields.
- The repository is **private to its domain**. Another domain reaching for it fails the arch test.

## 5. Create the query (`query.ts`)

A thin, public read namespace. Names are the concept, never `getX` / `fetchX`:

```ts
const byId = async (userId: UserId, id: ItemId) => {
  const item = await repository.findBy(userId, id)
  if (!item) return 'not-found' as const
  return item
}

export const ItemQuery = { all, byId, byStorage }
```

## 6. Create the command (`command.ts`)

The public write namespace. It returns the entity, or a **bare string sentinel** enumerating the
legitimate business outcomes — never `throw` for something the caller can expect:

```ts
const move = async (userId: UserId, id: ItemId, target: Attachment) => {
  const item = await repository.findBy(userId, id)
  if (!item) return 'not-found' as const
  if (target.storageId && target.zoneId) return 'invalid-location' as const
  // …
  await repository.save(moved)
  await emit('item-changed', { type: 'item-moved', item: moved })
  return moved
}
```

A command touches **its own domain only**. The moment it needs another domain's data — resolving
a storage into a full location path, deleting an item's reminders — that coordination moves to
`use-case.ts`.

## 7. Optional: business rules (`business-rules.ts`)

Pure, synchronous functions named after the concept. No `async`, no IO, no clock read inside (pass
`now` as an argument). They are covered by `business-rules.unit.test.ts` — aim for 100%, it is
cheap by construction.

```ts
export const nextDueDate = (current: Date, frequency: ReminderFrequency, now: Date): Date => …
export const nextOrder = (siblings: { order: number }[]) => …
```

Never `computeNextDueDate` / `handleOrder`: the name is the rule.

## 8. Optional: use case (`use-case.ts`)

Exists when one entry point coordinates several contexts. It calls public `Command` / `Query`
namespaces **only** — never a repository, its own included — and holds no business logic:

```ts
export const ItemUseCase = {
  // deleting an item must also drop the reminders that point at it
  remove: async (userId: UserId, id: ItemId) => {
    const outcome = await ItemCommand.remove(userId, id)
    if (outcome === 'not-found') return outcome
    await ReminderCommand.removeByItem(userId, id)
    return outcome
  },
}
```

Keep the dependency direction one-way: `item` orchestrates over `reminder`, so `reminder` must
never orchestrate back over `item`.

## 9. Optional: events (`events.ts`)

When another domain must *react* without being depended upon, publish instead of importing.
The event shape lives in the publishing domain; the subscription is wired in
`server/plugins/03-notifications.ts`:

```ts
export type LowStockCrossedEvent = { userId: UserId; itemId: ItemId; quantity: Quantity }
```

A handler failure must never fail the command that emitted the event.

## 10. Add the GraphQL slice

`infrastructure/graphql/{enums,types,inputs,queries,mutations}.ts`, then register the domain in
`server/domain/shared/graphql/schema.ts` with side-effect imports in dependency order (scalars
first, then enums → types → inputs → queries → mutations). New branded scalars are declared in
`builder.ts`'s `Scalars` map and registered in `scalars.ts`. Full patterns:
[graphql-patterns.md](./graphql-patterns.md).

Then regenerate the SDL and the iOS types:

```
bun run generate:graphql && bun run generate:ios
```

## 11. Write the tests

Co-located, with the suffix stating the level (the arch test enforces both):

- `*.unit.test.ts` — pure functions: `business-rules.ts`, `primitives.ts`, `events.ts`.
- `*.int.test.ts` — commands, queries and repositories against `server/test/fake-firestore.ts`.
  Assert three things: **behaviour** (what was persisted), **atomicity** (one committed batch, no
  stray direct writes) and the **read budget** (the exact number of reads, and that the second
  identical read in a request costs zero).
- `*.feat.test.ts` — a full GraphQL request through the schema, when the slice is worth it.

## Checklist

- [ ] `types.ts` — branded types, absence as optional fields, no Zod
- [ ] `primitives.ts` — one constructor per brand, imports `ts-brand` + `zod`
- [ ] `repository.ts` — owner-scoped, converter, memoized, private to the domain
- [ ] `query.ts` / `command.ts` — namespaces, intent-carrying names, sentinels not throws
- [ ] `business-rules.ts` pure and covered; `use-case.ts` repository-free
- [ ] GraphQL slice registered in `schema.ts`, every field documented
- [ ] `bun run generate:graphql` + `bun run generate:ios` committed
- [ ] `bun test` green, including `server/architecture.unit.test.ts`
- [ ] A migration if the change reshapes stored documents ([migrations.md](./migrations.md))
