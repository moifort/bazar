# GraphQL Patterns

How the schema is wired **in this repo**: Apollo Server 5 + Pothos 4, code-first, one endpoint
`POST /graphql`, one slice per domain. The portable rules — document everything, validate at the
boundary, never expose the storage shape, batch nested fields — are in
[graphql-best-practices.md](./graphql-best-practices.md). This document is the wiring.

## Layout — per-domain slices + shared plumbing

There is no central `server/graphql/` directory. Each domain owns:

```
server/domain/{domain}/infrastructure/graphql/
├── enums.ts        # domain unions → GraphQL enums
├── types.ts        # object types backing domain models
├── inputs.ts       # input objects
├── queries.ts      # builder.queryField(…)
└── mutations.ts    # builder.mutationField(…)
```

The plumbing lives in `server/domain/shared/graphql/`: `builder.ts`, `scalars.ts`, `schema.ts`,
`loaders.ts`, `errors.ts`.

## The builder and the context

`builder.ts` declares the single `SchemaBuilder`: the context shape, the default nullability, and
the map of branded scalars. Nothing else — no scalar implementation, no type.

```ts
export type GraphQLContext = {
  event: H3Event
  loaders: Loaders
  userId: UserId
}

export const builder = new SchemaBuilder<{
  Context: GraphQLContext
  DefaultFieldNullability: false
  Scalars: {
    DateTime: { Input: Date; Output: Date }
    ItemId: { Input: ItemId; Output: ItemId }
    // … one line per branded type crossing the wire
  }
}>({ defaultFieldNullability: false })
```

**`DefaultFieldNullability: false`** is the load-bearing setting: a field is non-null unless it
says otherwise, so nullability is a decision, never an oversight. `ctx.userId` is set by
`middleware/auth.ts` and is always present — a resolver never checks it.

## Branded scalars — validation at the boundary

Every domain identifier and every constrained string crosses the wire as its own scalar, not as
`String`. `scalars.ts` registers them all — including `DateTime` — and `parseValue` runs the
domain's Zod constructor through `validatedParse`, which turns a `ZodError` into a
`BAD_USER_INPUT` `GraphQLError` before any resolver runs:

```ts
builder.scalarType('ItemName', {
  description: 'Item name (non-empty, max 120 characters)',
  serialize: (value) => value as string,
  parseValue: validatedParse('ItemName', ItemName),
})
```

This is the Anti-Corruption Layer: **the value arrives branded**. Resolvers and commands take
`ItemId`, never `string`, and a cast (`id as ItemId`) anywhere downstream is a bug — see
[branded-types.md](./branded-types.md).

## Object types back domain models

An object type is declared with `builder.objectRef<Item>('Item').implement(…)` and exposes the
domain shape as the **product** describes it, not as Firestore stores it. Optional domain fields
(absent, never `null` — see [code-style.md](./code-style.md)) become `nullable: true` fields; the
conversion `undefined → null` happens here, at the boundary, and nowhere else.

```ts
export const ItemType = builder.objectRef<Item>('Item').implement({
  description: 'A household item stored in the inventory',
  fields: (t) => ({
    id: t.expose('id', { type: 'ItemId', description: 'Item unique identifier' }),
    quantity: t.expose('quantity', { type: 'Quantity', description: 'Number of identical items' }),
    lowStockThreshold: t.exposeInt('lowStockThreshold', {
      nullable: true,
      description: 'Quantity at or below which a low-stock notification fires. Absent = no alert.',
    }),
  }),
})
```

## Nested fields go through loaders — the N+1 budget

`Item.location` and `Item.reminders` are **derived** fields: they need another domain. Resolving
them per item would cost four extra reads per item (`storage → zone → room → place`), so a page
of 40 items would cost 160 reads. They resolve through the per-request loaders in
`shared/graphql/loaders.ts` instead:

```ts
location: t.field({
  type: LocationPathType,
  nullable: true,
  description: 'Resolved location path (storage or zone level)',
  resolve: (item, _args, ctx) => ctx.loaders.locationPath(item),
}),
```

Rules:

- A loader is **per request** — built in `routes/graphql.ts` from `createLoaders(userId)`, never
  module-level (it would leak one user's data into another's request).
- A loader batches by owner, not by id: the location tree of a single user is small, so one read
  per collection serves the whole page.
- A field that is not selected costs **nothing**: never prefetch in the parent resolver.
- The budget is asserted in tests (`fake.reads`), so an N+1 fails the build rather than the bill.

## Queries and mutations delegate — they hold no logic

A resolver does three things: read `ctx.userId`, call one `Query` / `Command` / `UseCase`, map the
outcome. No business rule, no Firestore, no orchestration.

```ts
builder.mutationField('moveItem', (t) =>
  t.field({
    type: ItemType,
    description: 'Move an item to another storage or zone',
    args: {
      id: t.arg({ type: 'ItemId', required: true }),
      input: t.arg({ type: MoveItemInput, required: true }),
    },
    resolve: async (_root, { id, input }, ctx) =>
      match(await ItemUseCase.move(ctx.userId, id, input))
        .with('not-found', 'invalid-location', 'location-not-found', domainError)
        .with(P.not(P.string), (item) => item)
        .exhaustive(),
  }),
)
```

## Mapping sentinels to GraphQLError

The sentinel **is** the error. `shared/graphql/errors.ts` exposes one `never`-returning helper
that throws it and derives the code mechanically (`'location-not-found'` → `LOCATION_NOT_FOUND`):

```ts
export const domainError = (sentinel: string): never => {
  throw new GraphQLError(sentinel, {
    extensions: { code: sentinel.toUpperCase().replaceAll('-', '_') },
  })
}
```

No hand-written per-site message, no local `new GraphQLError(...)` in a resolver. The match must be
**exhaustive** (`.exhaustive()`, never `.otherwise()`): adding a sentinel to a command becomes a
compile error until every resolver handles it. Full rationale:
[error-handling.md](./error-handling.md).

## Inputs

Input objects live in `inputs.ts` and use the branded scalars, so validation happens once. An
optional input field is `required: false` and arrives as `undefined` — the domain never receives
`null` from the API layer.

```ts
export const MoveItemInput = builder.inputType('MoveItemInput', {
  description: 'Target location: exactly one of storageId or zoneId',
  fields: (t) => ({
    storageId: t.field({ type: 'StorageId', required: false }),
    zoneId: t.field({ type: 'ZoneId', required: false }),
  }),
})
```

When exactly one of two fields is expected, say it in the description **and** return a sentinel
(`'invalid-location'`) from the command — the schema cannot express the constraint, the message
and the outcome must.

## Enums

A domain union of string literals (`ItemCategory`, `ReminderFrequency`) becomes a GraphQL enum in
`enums.ts`, keeping the English technical symbol as the value. The app owns the translation; the
schema never speaks the user's language.

## Document everything, functionally

Every type, field, argument and enum value carries a `description` written for someone who has
never seen the code: what it means in the domain, a concrete example, and what an absent value
*means*. See [graphql-best-practices.md](./graphql-best-practices.md#document-everything).

## Registering a slice

`schema.ts` assembles the schema through side-effect imports, in dependency order — scalars first,
then per domain `enums → types → inputs → queries → mutations`:

```ts
import '~/domain/shared/graphql/scalars'
import '~/domain/item/infrastructure/graphql/types'
// …
export const schema = builder.toSchema()
```

A type referenced before it is imported fails at boot, not at request time — which is why the
order is explicit and commented by domain.

## Regenerating the SDL and the iOS types

```
bun run generate:graphql   # → shared/schema.graphql
bun run generate:ios       # → ios/Bazar/Generated/GraphQL (Apollo codegen)
```

Both outputs are committed. A schema change that is not followed by both commands leaves the app
compiling against a schema that no longer exists.
