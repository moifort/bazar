# Project Directives

## Skills

The following skills cover coding conventions for this project. Invoke them when working on the relevant area:

- **`typescript-style`** — coding style, functional patterns, branded types, naming
- **`ddd-architecture`** — domain structure, CQRS, repositories, storage, migrations
- **`graphql-pothos`** — GraphQL schema with Pothos, custom scalars, documentation
- **`backend-testing`** — test levels (unit/int/feat), BDD DSL, coverage
- **`swiftui-expert-skill`** — SwiftUI patterns, @Observable, state management
- **`project-setup`** — CI/CD, Docker, README, CLAUDE.md templates
- **`feature-dev-workflow`** — full development cycle with convention review

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

## Environment Variables

Authentication:
- `NITRO_API_TOKEN` — API Bearer token (required)

External APIs:
- `NITRO_GOOGLE_API_KEY` — Gemini API key for photo analysis (item identification)

Always update `.env.example` and this section when adding new env vars.
