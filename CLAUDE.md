# Bazar - Project Directives

A household inventory: photograph your stuff, let the AI name and count it, know which room,
which shelf, which box it sits in — and get a push when something runs low.

## Language

Everything versioned and technical is **English**: commits, code, comments, docs, identifiers,
file names, GraphQL descriptions, AI prompts, test names, iOS accessibility *identifiers*.
Enum/union values are English technical symbols (`kitchenware`, `custom-days`,
`low-stock-crossed`) — the schema never speaks the user's language, the app translates. The
**only** French in the repo: user-facing copy (the iOS app's on-screen text and preview names,
the push notification body in `server/domain/notification/infrastructure/fcm.ts`) and French data
values quoted as examples in code, prompts and GraphQL descriptions. Never mix languages in a
commit message or a comment. Control: `grep -rnP '[\x{00C0}-\x{00FF}]' server/` must only return
those exceptions. Full rules: [docs/code-style.md](docs/code-style.md#language).

## Collaboration

> Full working agreement: [docs/collaboration.md](docs/collaboration.md) — read it at the start
> of any session. Key rules:

- **Docs are the spec**: align code to `docs/`, never the reverse; `docs/code-style.md` is law and is never edited to match the code (it changes only on an explicit user request). Corrections given in conversation are applied repo-wide **and** codified in the matching doc, in the same task.
- **Rules generic, wiring specific**: a practice that would hold in any codebase goes in a `*-best-practices.md` with neutral examples; how this repo implements it goes in the matching project guide, which links to the rule.
- **Work inline, never through subagents**: exploration, review, debugging and planning all happen in the main conversation — never `Task`/`Agent`, never a parallel-worker or subagent-driven skill, plan mode included.
- **Design talk is not a go**: in architecture discussions, "je veux faire X" is design intent — implement only on an explicit "vas-y" / "implémente" / "lance".
- **Every plan opens with a "Domaines impactés" block** (Créés / Modifiés / Supprimés) before the body.
- **No machine-local assistant memory**: collaboration learnings are written into `docs/`, nothing else.
- **Ops autonomy**: execute everything CLI-doable yourself; hand off only credential-gated steps, with numbered instructions.

## Build & Verification Commands

- **Backend typecheck**: `bun tsc --noEmit`
- **Regenerate types** (if routes changed): `bunx nitro prepare`; run it before `bun tsc`
- **Dev server**: `bun run dev` — Nitro on `http://localhost:3000` (GraphQL at `POST /graphql`)
- **Unit tests**: `bun test` — includes `server/architecture.unit.test.ts`, the executable conventions
- **Test coverage**: `bun run test:coverage`
- **Linter**: `bun run lint` (`bunx biome check`); autofix with `bun run lint:fix`
- **Runtime**: always use `bun`/`bunx`, never `npm`/`npx`
- **GraphQL codegen** (if the schema changed): `bun run generate:graphql` (regenerates `shared/schema.graphql`), then `bun run generate:ios`
- **iOS build**:
  ```
  DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project ios/Bazar.xcodeproj -scheme Bazar -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build
  ```

## Development Workflow

> **Git commit & push rules live in [docs/git-workflow.md](docs/git-workflow.md)** (portable rules:
> [docs/git-best-practices.md](docs/git-best-practices.md)) — read it at the start of any coding
> session. This section is the quick reference.

1. Verify the build before committing: `bun tsc --noEmit` and/or the iOS `xcodebuild`, depending on what was touched (`bunx nitro prepare` first if routes changed).
2. Review the diff yourself, **inline**, before committing — never through a subagent.
3. **Commit freely, one task = one commit**: commit each finished task without asking, never bundle tasks — a rollback is a clean `git revert`. English messages, Conventional Commits, `Co-Authored-By:` trailer.
4. **Close every task with the surfaces touched, then the diff size** ([docs/collaboration.md](docs/collaboration.md#closing-a-task-surfaces-then-diff-size)): one sentence on which of **the database**, **the backend** and **the iOS app** changed (the deployment blast radius), then `git show --stat HEAD | tail -1` and the lines added / removed — a refactor that only adds is a refactor that forgot to delete.
5. **Never push until the user explicitly says "push"**, and **never open a PR**: a push goes straight to `origin/main` (`git push origin HEAD:main`), whatever the working branch, following the [push protocol](docs/git-workflow.md#push-protocol-only-when-the-user-says-push) — reshape the pending commits, Biome autofix, regenerate the iOS GraphQL API if the schema changed, push, watch CI to green.
6. **Not at push time**: never touch `README.md` — it is updated on its own, when asked.

## Backend Patterns (TypeScript / Nitro)

> Extended guides live in `docs/`, split in two: the **rules**, written project-agnostic —
> [ddd-best-practices](docs/ddd-best-practices.md), [graphql-best-practices](docs/graphql-best-practices.md),
> [code-style](docs/code-style.md), [branded-types](docs/branded-types.md),
> [error-handling](docs/error-handling.md) — and this repo's **wiring** —
> [architecture](docs/architecture.md), [domain-guide](docs/domain-guide.md),
> [graphql-patterns](docs/graphql-patterns.md), [business-rules](docs/business-rules.md),
> [migrations](docs/migrations.md), [readme-guide](docs/readme-guide.md),
> [collaboration](docs/collaboration.md), [app-store-release](docs/app-store-release.md).
> This section is the quick reference.

- **Stack**: Bun + Nitro 2.13 (`preset firebase`, gen 2, nodejs22, `europe-west3`) + Apollo Server 5 + Pothos 4 + firebase-admin (native Firestore) + Zod + ts-brand. DDD/CQRS strict. Biome (spaces 2, single quotes, no semicolons, width 100), `ts-pattern` (`match().exhaustive()`), `lodash-es`.
- **Domains**: `server/domain/{item,location,reminder,notification,scan,search,dashboard,shared}` — `item`, `location`, `reminder` and `notification` persist; `scan` is ephemeral (previews are never stored); `search` and `dashboard` are read-only aggregations over the other domains' public `Query` namespaces. System concerns in `server/system/`. Standard layout (`types.ts`, `primitives.ts`, `command.ts`, `query.ts`, `infrastructure/{repository,graphql/*}.ts`, optional `business-rules.ts` / `use-case.ts` / `events.ts`): [docs/domain-guide.md](docs/domain-guide.md).
- **Branded types** (`ts-brand` + Zod constructors in `primitives.ts`: `ItemId`, `Quantity`, `StorageId`, `ReminderTitle`…); discriminated results for absence/errors (`'not-found' as const`) — no exceptions for control flow, **no `null` in the domain** (absence = `field?: T`, converted only at the GraphQL/Firestore boundaries).
- **Storage: native Firestore**, only inside `infrastructure/repository.ts`, via the `server/utils/firestore.ts` helpers and the per-request cache (`memoizedPerRequest`) — see [docs/architecture.md](docs/architecture.md#storage--native-firestore). Flat owner-scoped collections; **every query filters on `userId`**. Filtering, sorting and pagination happen in Firestore, never in memory.
- **GraphQL** (single endpoint `POST /graphql`): the location fields on `ItemType` resolve through the per-request loaders — never one read per item (N+1); read budgets asserted in tests via `fake.reads`. See [docs/graphql-patterns.md](docs/graphql-patterns.md).
- **Cross-domain reactions go through the event bus** (`emit` / `on`), never a direct import: `item` publishes `low-stock-crossed`, `notification` subscribes in `server/plugins/03-notifications.ts`.
- **Naming / ubiquitous language**: function names ARE the business concept (`nextOrder`, `nextDueDate` — never `computeX`, `handleX`); one business concept = one word at every layer (domain, GraphQL, iOS, tests). See [docs/domain-guide.md](docs/domain-guide.md#ubiquitous-language).
- **Tests**: `*.unit.test.ts` / `*.int.test.ts` with `bun:test`; Firestore mocked via `server/test/fake-firestore.ts`, which records batches and read counts to assert atomicity and read budgets.

## Key Business Rules

> Full model narrative: [docs/business-rules.md](docs/business-rules.md) — read it before touching
> `item`, `location`, `reminder` or the AI prompts. The invariants in one glance:

- **The location hierarchy is exactly four levels**: `place > room > zone > storage`, each pointing at its parent, siblings ordered by `order` (`nextOrder` = max + 1). Deleting cascades downward only. `fullPath` is derived at read time, never stored.
- **An item attaches to a storage OR a zone, never both** (`'invalid-location'`), possibly to nothing. `placeId` is denormalised at attach time and rewritten on every move.
- **Low stock is `quantity <= lowStockThreshold`**; the push fires on the **crossing** (was not low, is low now), not on every save. No threshold = no alert.
- **A scan produces previews, not items**: nothing is persisted until the user confirms the batch; a refused batch leaves no trace.
- **A reminder is recurring or one-shot** (absent frequency = one-shot); `customIntervalDays` belongs to `custom-days` and to nothing else. Completing reschedules (from the later of due date and completion date) or finishes and deletes. Deleting an item deletes its reminders.
- **Search and dashboard derive, never store** — no projection to fall out of sync.

## Database Migrations

- `server/system/migration/` — forward-only sequential migrations, no rollback, triggered by `POST /admin/migrate` (CI deploy / provisioning). When to migrate, how to write and register one: [docs/migrations.md](docs/migrations.md).
- Every schema-shape change needs its migration **and** its `.int.test.ts` — including dropping a `null` in favour of an absent field.

## iOS Patterns (SwiftUI)

> Full iOS guide: [docs/ios-guide.md](docs/ios-guide.md) — project wiring; the portable SwiftUI
> rules live in [docs/swiftui-best-practices.md](docs/swiftui-best-practices.md).

- Target iOS 26.0, Swift 6 (strict concurrency). XcodeGen (`ios/project.yml` is the source, `ios/Bazar.xcodeproj` is generated), scheme `Bazar`, bundle id `co.polyforms.bazar`, team `46C337T7YN`. MVVM with `@Observable` (`@MainActor` ViewModels, `Sendable` models), Apollo iOS codegen, Firebase Auth + Sign in with Apple, Firebase Messaging for push.
- Style: **Liquid Glass** = native iOS 26 components (no custom re-skins). Feature structure `Features/{Feature}/components/{pages,organisms,molecules,atoms}/`, shared atoms in `Shared/Components/`.
- **Generated Apollo types stop at `{Feature}API.swift`** — nothing above that boundary imports `BazarGraphQL`. **Primitive-first leaf views**; **pages = pure presentation**, coordinators (`{Feature}View.swift`) own navigation, sheets and network calls; **previews as Storybook** (everything below page level previewable offline); **a CTA that hits the network shows it** (`AsyncToolbarButton`, optimistic deletes — never `.disabled(...)` alone).
- Never add files through Xcode's UI: write the file, re-run `xcodegen generate` if a folder appeared. `DEVELOPER_DIR` is required because `xcode-select` points to CommandLineTools.

## App Store Distribution

Full release flow — latest **final** Xcode only (ITMS-90111), the beta-macOS `BuildMachineOSBuild`
patch, the `CURRENT_PROJECT_VERSION` bump in `ios/project.yml`:
[docs/app-store-release.md](docs/app-store-release.md).

## Gemini API Key & Secrets

- The AI (photo scan) is **Gemini 2.5 Flash** in `server/domain/scan/infrastructure/gemini.ts`, key in `NITRO_GOOGLE_API_KEY`; `POST /admin/migrate` is gated by `NITRO_ADMIN_TOKEN`. Local `.env` (see `.env.example`); in production, GCP Secret Manager (project `polyforms-bazar-prod`), provisioned by `infra/secrets.tf`. Never commit a key. Always update `.env.example` and this section when adding an env var.

## iOS Simulator

- Device: iPhone 17, OS 26.2
- **After finishing any iOS task**, build and launch the app in the simulator on your own — do not ask first. When the task touched UI, launch straight into the affected screen with DebugGallery (`xcrun simctl launch booted co.polyforms.bazar -gallery <screen>`) and screenshot it to verify the change visually before reporting. Screens = the `switch` cases in `ios/Bazar/Shared/DebugGallery.swift`; add a case if the touched screen has none.

## iOS Physical Device Install

- After finishing a task (especially one touching iOS), **offer** to install it on the physical iPhone "TiPhone junior" (UDID `00008130-000A2068029A001C`, automatic dev signing, team `46C337T7YN`). Never install automatically — ask first, run only after a yes.
- On a yes, run `scripts/install-device.sh` to build → install → launch. The device must be connected, unlocked, and trusted. Relay the raw `xcodebuild`/`devicectl` output — don't claim success without it.
