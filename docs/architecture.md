# Backend Architecture

## Overview

The backend follows a strict Domain-Driven Design (DDD) / CQRS architecture built on
[Nitro](https://nitro.build/) (preset `firebase`, Firebase Cloud Functions Gen 2), with
TypeScript, **native Firestore** storage (`firebase-admin`), branded types, and a single
GraphQL endpoint (Apollo Server + Pothos).

## The rules behind it

The DDD/CQRS rules this structure implements — bounded-context layout, sentinels over exceptions,
private repositories, pure business rules, derived reads — are written project-agnostically in
[ddd-best-practices.md](./ddd-best-practices.md). This document only describes **where** they land
here. Most of them are **enforced by `server/architecture.unit.test.ts`**, the executable source of
truth; the style rules that go with them are in the [code style guide](./code-style.md).

Concretely, in this repo: a bounded context is `server/domain/{domain}/`; Value Objects and Entities
are the branded types in `types.ts`; the Anti-Corruption Layer is the Zod validation carried by the
GraphQL scalars; `'not-found' as const` is the sentinel shape.

## Directory Structure

```
server/
├── architecture.unit.test.ts   # project-wide convention tests (source of truth)
├── domain/                      # business logic (DDD bounded contexts)
│   ├── shared/                  # cross-domain types + the GraphQL plumbing
│   │   ├── types.ts             # UserId
│   │   ├── primitives.ts        # their Zod constructors
│   │   └── graphql/             # builder.ts, scalars.ts, schema.ts, loaders.ts, errors.ts
│   ├── item/                    # the objects the user owns — the central domain
│   ├── location/                # place > room > zone > storage hierarchy
│   ├── reminder/                # maintenance reminders attached to an item
│   ├── notification/            # push subscriptions + FCM delivery
│   ├── scan/                    # photo → item previews (Gemini vision)
│   ├── search/                  # cross-entity fuzzy search (read-only)
│   └── dashboard/               # home-screen aggregation (read-only)
├── routes/                      # HTTP endpoints (auto-scanned by Nitro)
│   ├── graphql.ts               # GET/POST /graphql → Apollo
│   ├── health.get.ts            # GET /health → unauthenticated liveness probe
│   └── admin/migrate.post.ts    # POST /admin/migrate → runs migrations
├── middleware/auth.ts           # Firebase ID token / admin token auth (H3 middleware)
├── plugins/
│   ├── 01-sentry.ts             # error reporting (Sentry, DSN from NITRO_SENTRY_DSN)
│   ├── 02-graphql.ts            # boots ApolloServer once with the assembled schema
│   └── 03-notifications.ts      # subscribes the notification domain to domain events
├── system/                      # infrastructure concerns
│   ├── account/                 # deleteAccount — asks each domain to forget, then Auth
│   ├── config/                  # runtime config (env)
│   ├── changelog/               # parses the shipped CHANGELOG.fr.md into the app's "Nouveautés"
│   ├── migration/               # runner.ts, types.ts, primitives.ts, migrations/
│   ├── changelog-content.ts     # generated from CHANGELOG.fr.md, gitignored
│   ├── event-bus.ts             # in-process domain event bus
│   ├── logger.ts                # consola tagged loggers
│   ├── firebase.ts              # firebase-admin init + db()
│   └── request-cache.ts         # per-request memoization
├── utils/
│   ├── firestore.ts             # genericDataConverter and friends
│   └── apollo.ts                # setApollo / useApollo holder
└── test/fake-firestore.ts       # in-memory Firestore fake with read/write accounting
```

Not every domain has every file. `item`, `location`, `reminder` and `notification` persist and own
a repository; `scan` is ephemeral (a photo analysis is previewed and confirmed, never stored as
such); `search` and `dashboard` are **read-only** — no `command.ts`, no repository, they assemble
data through other domains' public `Query` namespaces.

## Layers

### Domain Layer (`server/domain/`)

Each domain is a self-contained bounded context. The per-file responsibilities are the generic ones
([ddd-best-practices.md](./ddd-best-practices.md#the-building-blocks-and-where-they-live)); what is
specific here:

- **types.ts** — branded types via `ts-brand`. No Zod here.
- **primitives.ts** — Zod constructors; must import both `ts-brand` and `zod` (checked by the arch test).
- **command.ts** / **query.ts** — exported as a namespace object (`ItemCommand`, `LocationQuery`).
  See [error handling](./error-handling.md) for the sentinel → `GraphQLError` mapping.
- **business-rules.ts** — pure, synchronous, and covered by `business-rules.unit.test.ts`.
- **use-case.ts** — multi-domain orchestration (`ItemUseCase` coordinates `item`, `location` and
  `reminder`); the no-repository rule is enforced by the arch test.
- **events.ts** — the domain's event shapes, published on the [event bus](#domain-events).
- **infrastructure/repository.ts** — the **only** place `db()` is used.
- **infrastructure/graphql/** — the domain's slice of the Pothos schema.

### The location hierarchy

`location` owns four collections forming a strict four-level chain — `place > room > zone >
storage` — each document pointing at its parent (`Room.placeId`, `Zone.roomId`,
`Storage.zoneId`) and carrying an `order` for user-defined sorting. An item attaches to a
**storage** or to a **zone**, never to both, and its `placeId` is denormalised at attach time so
that place-scoped reads stay one query. The rules that follow from this (`fullPath`, `nextOrder`,
`sortByOrder`) live in `location/business-rules.ts`; see [business-rules.md](./business-rules.md).

### Storage — native Firestore

Storage is native Firestore via `firebase-admin`, reached through `db()` from
`server/system/firebase.ts`, and used **only** inside `infrastructure/repository.ts`.

Every collection reference is wrapped with `genericDataConverter<T>()` (from
`server/utils/firestore.ts`), which gives typed reads and recursively turns Firestore
`Timestamp` values back into JS `Date`:

```ts
const items = () => db().collection('items').withConverter(genericDataConverter<Item>())
```

Collections are flat and owner-scoped: `items`, `places`, `rooms`, `zones`, `storages`,
`reminders`, `reminder-completions`, `notification-subscriptions`. **Every query filters on
`userId`** — multi-tenancy is not a filter the caller can forget. Firestore is initialised with
`ignoreUndefinedProperties: true`, which is what lets the domain express absence as a missing
field rather than `null` (see [code-style.md](./code-style.md)).

Filtering, sorting and pagination happen **in Firestore**, not in memory: a query composes
`where` + `orderBy` + `startAfter(cursor)` + `limit(n + 1)` to derive `hasMore`. Composite indexes
are declared in `firestore.indexes.json` and provisioned by `infra/firestore.tf`. Beware: Firestore
silently drops documents that lack the sorted field — only sort or paginate on fields present on
every document.

### Read side — no `read-model/` layer

There is **no** `read-model/` directory and no stored projection. Composite reads are served two
ways:

1. **Read-only domains** — `search` and `dashboard` expose a `query.ts` that assembles data
   through other domains' public `Query` namespaces. They never touch a repository.
2. **GraphQL loaders** — the location fields grafted onto `ItemType` resolve through the
   per-request, batched loaders in `server/domain/shared/graphql/loaders.ts`, so a page of items
   never triggers N+1 reads. See [graphql-patterns.md](./graphql-patterns.md).

Repeated reads within a single request are collapsed by the **request cache**
(`memoizedPerRequest` in `server/system/request-cache.ts`).

### Domain events (`server/system/event-bus.ts`)

Bazar has one cross-domain concern that must not become a dependency: a quantity dropping below
its low-stock threshold has to reach the user's phone. Rather than letting `item` import
`notification`, `item` **publishes** (`emit('low-stock-crossed', …)`) and `notification`
**subscribes**, wired once at boot in `server/plugins/03-notifications.ts`. The bus is
in-process and fire-and-forget: handlers are awaited, but a failing handler must never fail the
command that published the event. Event shapes live in the publishing domain's `events.ts`.

### GraphQL Layer — per-domain, not central

Code-first GraphQL (Apollo Server 5 + Pothos 4), exposed at the single endpoint `POST /graphql`.
There is **no** central `server/graphql/` directory: each domain owns its slice under
`infrastructure/graphql/{enums,types,inputs,queries,mutations}.ts`. The shared plumbing lives
in `server/domain/shared/graphql/`:

- **builder.ts** — the single Pothos `SchemaBuilder`; declares the `GraphQLContext`
  (`{ event, userId, loaders }`), `DefaultFieldNullability: false`, and the branded `Scalars` map.
- **scalars.ts** — registers every scalar (including `DateTime`); `parseValue` runs the domain's
  Zod constructor, turning a `ZodError` into a `BAD_USER_INPUT` `GraphQLError`.
- **schema.ts** — assembles the schema by **side-effect imports** in dependency order
  (`./scalars` first, then each domain's `enums/types/inputs/queries/mutations`).
  Ends with `export const schema = builder.toSchema()`.
- **loaders.ts** — the per-request location loaders used by `ItemType`.
- **errors.ts** — the `never`-returning `domainError` resolver helper that maps a command sentinel
  to a `GraphQLError`, deriving `extensions.code` mechanically from the sentinel
  (`'not-found'` → `NOT_FOUND`); it sits in `match().exhaustive()` arms. See
  [error-handling.md](./error-handling.md).

The SDL is exported to `shared/schema.graphql` (`bun run generate:graphql`) for Apollo iOS codegen.

### Route Layer (`server/routes/`)

The app is GraphQL-first; only three HTTP handlers exist:

- `routes/graphql.ts` — `GET`/`POST /graphql`; builds a fresh per-request context
  `{ event, userId, loaders: createLoaders(userId) }` and forwards to Apollo.
- `routes/health.get.ts` — unauthenticated liveness probe for Cloud Run.
- `routes/admin/migrate.post.ts` — `POST /admin/migrate` (see [migrations.md](./migrations.md)).

`middleware/auth.ts` runs for every route: `/health` is public, `/admin/*` requires the admin
bearer token (`adminToken`); everything else (including `/graphql`) requires a valid Firebase ID
token and sets `event.context.userId`.

### System Layer (`server/system/`)

Infrastructure concerns only: `config` (runtime env), `migration`, `firebase` (`db()`),
`event-bus`, `logger`, `request-cache`. No business logic lives here.

## Cross-Domain Rules

The isolation rules — private repositories, validation at the boundary, no storage outside
repositories, names that carry intent, no `throw` for expected outcomes — are stated in
[ddd-best-practices.md](./ddd-best-practices.md#purity-and-isolation-rules). Here they are
**executable**: `server/architecture.unit.test.ts` walks `server/` and fails `bun test` on any
violation.

## Data Flow

**Simple read/write (single domain):**
```
GraphQL request → /graphql → Apollo → Pothos resolver → domain Query/Command → repository → Firestore
```

**Nested field (item location):**
```
Pothos resolver → loaders.<entity>.load(id) → (batched) domain Query → single owner-scoped read
```

**Orchestrated write (multi-domain):**
```
Pothos mutation → use-case → several Commands/Queries → repositories
```

**Reaction (event):**
```
Command → emit('low-stock-crossed') → notification handler → FCM push
```

## Observability

Logging goes through `server/system/logger.ts` (`consola`, one tagged logger per module) — the
arch test bans `console.log|error|warn` in server code, the migration runner's `console.info`
aside. Expected 4xx (401 missing user, 404, `BAD_USER_INPUT`) are business outcomes, not
incidents, and must never be logged as errors.

Error reporting is wired in `server/plugins/01-sentry.ts` via `@sentry/node`, with the DSN read
from `NITRO_SENTRY_DSN` (Secret Manager in production, `.env` locally). A blank or invalid DSN
disables reporting, so a bad value never breaks the deploy — a DSN Sentry's SDK rejects at
`init()` would fail the Cloud Run health check and take the whole release down. The plugin hooks
Nitro's `error` event and captures only faults with no `statusCode` or one `>= 500`; anything the
API answered as a 4xx is dropped on the floor. Whatever escapes both also lands in Cloud Logging.

The backend reports to the `bazar-server` project of the `polyforms` Sentry organisation, its DSN
carried by the `SENTRY_DSN` repository secret and handed to Terraform as `sentry_dsn`. The iOS app
has its own project (`bazar-ios`, DSN hardcoded — see
[ios-guide.md](./ios-guide.md#error-reporting--sentry)), so a fault in the API is never mixed up
with a crash on the phone.
