# Git Workflow — Commits & Push

This repo's git policy — how work is checkpointed locally and shipped to the remote. The portable
rules it builds on (one task one commit, verify before committing, Conventional Commits, revert over
surgery, reshape before pushing) are in [git-best-practices.md](./git-best-practices.md). CLAUDE.md's
*Development Workflow* section is the quick reference; this doc is the full spec.

## What the generic rules mean here

- **Language**: git history is **English** — commit messages and branch names included. The only
  French in the repo is user-facing copy (the iOS app's on-screen text, the push notification
  body). Never mix languages inside a message.
- **Verify before committing**: backend `bun tsc --noEmit` (run `bunx nitro prepare` first if
  routes changed) and/or the `xcodebuild` iOS build, depending on what was touched; `bun test`
  whenever the change has a testable surface — it also runs
  `server/architecture.unit.test.ts`, which is what catches a convention violation before the
  reviewer does.
- **Review before committing**: read your own diff **inline**, in the session — never through a
  subagent (see [collaboration.md](./collaboration.md#work-inline-never-through-subagents)).
- **Commit trailer**: every message ends with the `Co-Authored-By:` trailer.
- **Scopes** used here: `ios`, `server`, `infra`, `docs`, or a domain name (`item`, `location`,
  `reminder`, `notification`, `scan`, `search`, `dashboard`).

## Branching

Commit on the working branch (usually **`main`**) — this project commits freely to `main` by
convention, so the generic "branch first before committing" rule does **not** apply here. Only
branch when the user asks for one.

## Never open a pull request

This is a solo project: CI (Unit Tests + Deploy) runs on `main` pushes only, so a pull request
is pure ceremony. **Never open one, never suggest one.** On "push", the work goes straight to
`origin/main` — even from a feature branch (see *Push protocol* below).

## Never push until asked

**Never push until the user explicitly says "push".** Commits accumulate locally; pushing is
user-gated. Approval to commit is never approval to push.

## Push protocol (only when the user says "push")

1. **Re-analyze & reshape the pending commits** — the generic rule
   ([reshape before pushing](./git-best-practices.md#reshape-local-commits-before-they-leave-the-machine)):
   list them with `git log origin/<branch>..HEAD`, squash/regroup, rewrite messages, and elide
   undone work so a feature plus its revert leaves no trace on the remote.
2. **Biome autofix.** Run `bun run lint:fix` (`bunx biome check --write`) to correct every
   auto-fixable formatting/syntax issue across the repo — including vendored/generated files like
   asset-catalog `Contents.json`, which CI's `bunx biome check` lints too. Then run `bun run lint`
   to confirm it's clean, and commit any changes. This is what keeps the Unit Tests job green — a
   local `bun test` alone does **not** cover Biome.
3. **iOS GraphQL API** (only if the GraphQL schema changed): run `bun run generate:graphql`,
   then `bun run generate:ios`, and commit the regenerated `shared/schema.graphql` and the
   generated Apollo operations so the app's typed operations stay in sync with the deployed schema.
4. **Migrations** (only if a document shape changed): make sure the migration is registered in
   `server/system/migration/migrations/index.ts` and covered by its `.int.test.ts` — the deploy
   calls `POST /admin/migrate` right after `terraform apply`, and a failing migration fails the
   deploy.
5. **Push — straight to `origin/main`.** `git push origin HEAD:main` (fast-forward), whatever
   the working branch — never via a pull request. Realign local `main` afterwards.
6. **Analyze the CI.** A push to `main` fires two workflows — **Unit Tests** and **Deploy**.
   Watch them through to completion rather than assuming green: `gh run watch`, or
   `gh run list --branch main --limit 5` then `gh run view <id> --log-failed` on any failure.
   The push isn't done until CI is green; if a job fails, report it and fix it (a follow-up
   commit + push), don't leave a red `main`.

## Not at push time

Never touch `README.md` while pushing — it is updated on its own, when asked. A `main` push is
code, not documentation housekeeping.
