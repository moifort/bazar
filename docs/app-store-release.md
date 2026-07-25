# App Store Release

How a Bazar build reaches the App Store. **A release is a tag**: everything after it is CI's job —
archive, upload, listing, review submission, publication. This is a release-time procedure, none
of it belongs to a normal push (see [git-workflow.md](./git-workflow.md)).

## The release, in five steps

1. **Write the notes.** English under `## Unreleased` in `CHANGELOG.md`, French under
   `## Unreleased` in `CHANGELOG.fr.md` — how to word them:
   [changelog-best-practices.md](./changelog-best-practices.md). Version both sections
   (`## 1.1 (2026.08.02)`): a section still called `Unreleased` is what the guard refuses.
2. **Bump the version** in `ios/project.yml` — `MARKETING_VERSION` if the version moves — and
   re-run `xcodegen generate`. Never edit `ios/Bazar.xcodeproj` by hand. The **build number** is
   not bumped by hand: CI passes the workflow run number, which only ever grows, and App Store
   Connect rejects a number it has already seen.
3. **Deploy the backend first.** The app talks to one GraphQL endpoint, so a schema the shipped
   binary does not know about is a broken release. The deploy also rebuilds
   `server/system/changelog-content.ts` from `CHANGELOG.fr.md` — **without it the in-app
   "Nouveautés" list stays stale**, since the backend serves it.
4. **Tag and push it.** The tag is platform-prefixed so the backend keeps its own tags free:

   ```bash
   git tag ios-v1.1 && git push origin ios-v1.1
   ```

5. **Watch the Release workflow.** `gh run watch`. It selects the newest Xcode on the runner,
   guards the release, generates the typed GraphQL API, builds, uploads, delivers the listing,
   submits for review and — last — publishes the GitHub release.

**The tag is the last human act.** `submit_for_review` and `automatic_release` are both on: the
build goes on sale the moment Apple approves it, with nobody in between. A version that should not
ship on approval is a version that should not have been tagged.

## What the guard catches

`bun scripts/release-notes.ts guard <version>` runs before anything reaches Apple and fails on:

- a tag that disagrees with `MARKETING_VERSION` — otherwise the upload is labelled with someone
  else's version number, which App Store Connect accepts silently;
- a changelog section still called `## Unreleased`, in either language;
- a version with no section at all.

The same script feeds the two audiences afterwards: `notes <version>` prints the French bullets
flat (the store shows one plain list and would print `###` literally) for the "What's New" field,
`markdown <version> en` prints the English section untouched for the GitHub release.

## The listing lives in the repository

`fastlane/metadata/` holds the name, subtitle, description, keywords, categories and URLs, and
`deliver` pushes them on **every** release, overwriting whatever App Store Connect holds. Editing
those texts in the web console is therefore pointless — the next release wipes them.

Two deliberate exceptions:

- **Screenshots are uploaded by hand** (`skip_screenshots`). They change when the interface
  changes, which is not a release's rhythm, and generating them in CI cost more than it returned.
  Regenerate them locally, look at them, drop them in.
- **The age rating is not declared here.** Apple requires attributes fastlane's rating config
  cannot express, and a delivery that omits them is rejected outright. It is set once, on the app
  rather than on a version — nothing about it changes from one release to the next.

## Signing needs no certificate on disk

Cloud signing: Xcode fetches the distribution certificate and profile itself, given an App Store
Connect API key. CI holds three secrets — `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8` — and the
Fastfile writes the key under `build/`, which git ignores and the runner throws away.

## The two public pages App Store Connect asks for

A listing needs a **privacy policy URL** and a **support URL**, both reachable without an account.
They live in `docs/pages/` as two static files and are published by the Pages workflow on every
push that touches them:

- <https://moifort.github.io/bazar/privacy.html>
- <https://moifort.github.io/bazar/support.html>

Keep them true to the app, not to an intention: the privacy page names every piece of data
collected, who processes it, and how long it is kept — including that a scan photo is analysed and
thrown away rather than stored. A page that promises less than the app does is a rejection; one
that promises more is worse.

## Xcode version

Build with the latest **final** Xcode — never a beta or RC, and never an older release once a
newer final has shipped. Both are rejected on upload with **ITMS-90111** (unsupported SDK or Xcode
version). The workflow picks the newest `/Applications/Xcode*.app` on the runner for exactly this
reason; the constraint only bites when releasing by hand.

## Releasing by hand (when CI cannot)

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project ios/Bazar.xcodeproj -scheme Bazar \
  -destination 'generic/platform=iOS' \
  -archivePath build/Bazar.xcarchive archive
```

then `-exportArchive` with the App Store export options, and upload through Xcode Organizer or
`xcrun altool`.

### Beta-macOS build machines

If the dev Mac runs a **beta macOS**, the archive carries a prerelease `BuildMachineOSBuild` stamp
that App Store validation also rejects with ITMS-90111. Patch it to the latest **public** macOS
build number after archiving and *before* `-exportArchive` — export re-signs, so the patch
survives:

```bash
plutil -replace BuildMachineOSBuild -string '<latest public macOS build>' \
  build/Bazar.xcarchive/Products/Applications/Bazar.app/Info.plist
```

Look up the current public macOS build at https://developer.apple.com/news/releases. Check that
`DTXcodeBuild` and `DTSDKBuild` are untouched, then export. The clean alternative is to archive on
a non-beta macOS — no patch needed. CI never hits this: the runner is not on a beta.
