# Project Directives

## Build & Verification Commands

- **Backend typecheck**: `bun tsc --noEmit`
- **Regenerate types** (if routes changed): `bunx nitro prepare` (run before `bun tsc`)
- **Regenerate GraphQL schema**: `bun run generate:graphql` (run after modifying Pothos types/queries/mutations)
- **Unit tests**: `bun test`
- **Test coverage**: `bun test --coverage`
- **Linter**: `bunx biome lint --fix`
- **Runtime**: always use `bun`/`bunx`, never `npm`/`npx`

## Development Workflow

1. Always verify the build before committing: `bun tsc --noEmit`
2. Run `bunx nitro prepare` before `bun tsc` if routes were added/modified
2b. Run `bun run generate:graphql` if GraphQL schema changed (Pothos types/queries/mutations)
3. Run tests before committing: `bun test`
4. Run `bunx biome check --write` to auto-fix formatting and lint
5. Fix remaining lint errors. `biome-ignore` is exceptional — only when justified, with an explanation

## Commit Strategy

- **Conventional Commits**: `type(scope): description` — types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`
- **Scopes**: domain name for business changes (`feat(item): ...`, `feat(location): ...`), technical name otherwise (`fix(migration): ...`, `chore(deps): ...`). Omit scope if too broad
- **Commit after each verified task**: all checks pass (build + tests + lint) before committing
- **Fine granularity, functional coherence**: each commit = one logical change

## Backend Patterns (TypeScript/Nitro)

- Domain architecture: `server/domain/{domain}/types.ts`, `primitives.ts`, `repository.ts`, `command.ts`, `query.ts`
- **`business-rules.ts`** (optional): pure functions (no IO, no async) extracted from complex commands. Function names ARE the business concept. Must have 100% test coverage (`business-rules.unit.test.ts`)
- **`use-case.ts`** (optional): multi-domain orchestrations when a route needs to coordinate several commands/queries. Names carry business intent. No direct storage access.
- Branded types with `ts-brand` + Zod validation constructors in `primitives.ts`
- **Branded types are primitives at runtime** — never wrap with `String()` or `Number()`. The brand is compile-time only.
- **Always use branded types** for structured values (URLs, IDs, names, etc.) — never raw `string`
- **Never add a boolean** when its truth is derivable from another field
- Discriminated unions for expected business outcomes only (not technical errors). `throw` for impossible states
- File-based storage: `useStorage('namespace')`
- **Naming**: function names carry the business concept, not the technical pattern
- **BDD DSL**: `server/test/bdd.ts` — `feature()`, `scenario()`, `given()`, `when()`, `then()`, `and()` over `bun:test`. Feature tests use `.feat.test.ts` suffix.
- Formatter: Biome (spaces, single quotes, no semicolons, line width 100)
- Logging: `createLogger(tag)` from `~/system/logger` — never use raw `console.log/error`

### GraphQL Layer

- **Stack**: Apollo Server + Pothos (code-first schema builder)
- **Endpoint**: `/graphql`
- **Domain-scoped**: `server/domain/{domain}/infrastructure/graphql/` — types, queries, mutations, inputs, enums
- **Documentation**: every type, field, enum, argument gets a `description` (visible in Apollo Sandbox)
- **Schema SDL**: exported to `shared/schema.graphql` via `bun run generate:graphql`
- **Enums lowercase**: GraphQL enum values match the domain in lowercase. If a domain value contains a hyphen, use a custom scalar with the domain primitive instead of an enum
- **Errors**: `GraphQLError` with `extensions.code` for business errors (`NOT_FOUND`)
- **Custom scalars**: every branded type in `primitives.ts` must have a corresponding Pothos custom scalar
- **Domain-first changes**: GraphQL type changes must always be reflected in domain types and primitives first. Order: (1) `types.ts`, (2) `primitives.ts`, (3) GraphQL layer, (4) commands/queries

## Backend Testing

- **Framework**: `bun:test` (native, zero dependencies)
- **Test files co-located** next to the file under test (no `__test__/` directories)
- **Suffixes**: `*.feat.test.ts` (feature), `*.int.test.ts` (integration), `*.unit.test.ts` (unit)
- **Infrastructure**: `server/test/setup.ts` (mock useStorage in-memory) + preloaded via `bunfig.toml`

## Code Style

- **Never type return values** — let TypeScript infer
- **Full variable names** — `migration` not `m`
- **Destructure in callbacks** — `({ version }) => version`
- **Inline single-line guards** — `if (...) return ...` on one line
- **`as const` on all literal returns**
- **Use `Date` type** — not `string` for dates
- **Use lodash-es** — `sortBy`, `keyBy`, `uniq` with destructured callbacks
- **Never `switch`** — use `match()` from `ts-pattern` with `.exhaustive()`
- **Never `for`/`while` loops** — use `map`/`filter`/`reduce`, chaining, and lodash-es utilities
- **Arrays never optional** — `[]` is the neutral state, never `null`/`undefined`
- **Never `String()`/`Number()` on branded types** — they ARE the underlying primitive at runtime
- **All code in English** — comments, descriptions, variable names. French only for i18n values.
- **Always update .env.example and CLAUDE.md** when adding new env vars

## API Keys & Token

The API token is used for authentication when `NITRO_API_TOKEN` is set:
- `.env` (`NITRO_API_TOKEN=...`)

External API keys:
- `NITRO_GOOGLE_API_KEY` — Gemini API key for photo analysis (item identification)
