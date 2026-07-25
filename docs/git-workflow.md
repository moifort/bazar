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

## Staging: only your own task

Sessions share the primary checkout (no worktrees, see
[Never work in a git worktree](#never-work-in-a-git-worktree)), so files you did not touch may
belong to a session still running or to work left in progress. **Stage the explicit paths of
your task**, then commit — never `git add -A`, `git add .` or `git commit -a`. Check `git show
--stat HEAD` after committing: an unexpected file in the list means you took someone else's work.

## Branching

Commit on the working branch (usually **`main`**) — this project commits freely to `main` by
convention, so the generic "branch first before committing" rule does **not** apply here. Only
branch when the user asks for one.

## Never work in a git worktree

**Work in the main checkout, never in a `git worktree`.** Everything lands on `main` here, so an
isolated worktree buys nothing and costs plenty: it starts from `origin/main` and therefore misses
unpushed local commits, it needs its own `bunx nitro prepare` and its own SwiftPM resolve before
anything typechecks or builds, and it splits the Xcode DerivedData the codegen script looks in.
If an agent harness offers to isolate the session in one, decline and stay in the main checkout.

## Never open a pull request

This is a solo project: CI (Tests + Deploy) runs on `main` pushes only, so a pull request
is pure ceremony. **Never open one, never suggest one.** On "push", the work goes straight to
`origin/main` — even from a feature branch (see *Push protocol* below).

The one exception is **Renovate**, which opens its own dependency PRs and merges them itself once
the test workflows pass — the PR is the bot's review surface, not ours. `renovate.json` groups
every non-major bump into a single squashed automerged PR, keeps majors separate, and pins the two
versions the Cloud Function build cannot survive (`graphql` < 17, `firebase-admin` < 14 — the Nitro
firebase preset installs `firebase-functions@latest` with npm, whose peer ranges reject them).
Leave those pins in place; a red Renovate PR is a real incompatibility, not a flake.

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
   to confirm it's clean, and commit any changes. This is what keeps the Tests / Unit job (which
   runs `biome check`) green — a local `bun test` alone does **not** cover Biome.
3. **iOS GraphQL API** (only if the GraphQL schema changed): run `bun run generate:graphql`,
   then `bun run generate:ios`, and commit the regenerated `shared/schema.graphql` and the
   generated Apollo operations so the app's typed operations stay in sync with the deployed schema.
4. **Migrations** (only if a document shape changed): make sure the migration is registered in
   `server/system/migration/migrations/index.ts` and covered by its `.int.test.ts` — the deploy
   calls `POST /admin/migrate` right after `terraform apply`, and a failing migration fails the
   deploy.
5. **Push — straight to `origin/main`.** `git push origin HEAD:main` (fast-forward), whatever
   the working branch — never via a pull request. Realign local `main` afterwards.
6. **Analyze the CI.** A push to `main` fires the test workflows (**Tests**: Unit, Integration,
   Feature — plus the npm strict-peer-deps guard) and **Deploy**.
   Watch them through to completion rather than assuming green: `gh run watch`, or
   `gh run list --branch main --limit 5` then `gh run view <id> --log-failed` on any failure.
   The push isn't done until CI is green; if a job fails, report it and fix it (a follow-up
   commit + push), don't leave a red `main`.

## Not at push time

Never touch `README.md` while pushing — it is updated on its own, when asked. A `main` push is
code, not documentation housekeeping.
