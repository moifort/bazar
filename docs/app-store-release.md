# App Store Release

How a Bazar build reaches the App Store. This is a release-time checklist — none of it belongs to
a normal push (see [git-workflow.md](./git-workflow.md)).

## Xcode version

Build with the latest **final** Xcode — never a beta or RC, and never an older release once a
newer final has shipped. Both are rejected on upload with **ITMS-90111** (unsupported SDK or Xcode
version).

## Release flow

1. Write the release notes in English under `## Unreleased` in `CHANGELOG.md`, then the French
   translation under `## Unreleased` in `CHANGELOG.fr.md` — how to word them:
   [changelog-best-practices.md](./changelog-best-practices.md). Version both sections at release
   time (`## 1.1 (2026.08.02)`); `## Unreleased` left behind is what
   `bun scripts/release-notes.ts guard <version>` refuses to release.
2. Bump `CURRENT_PROJECT_VERSION` — every upload to App Store Connect needs a build number higher
   than the last one, even when the marketing version does not move. It lives in
   `ios/project.yml`, which is the source: change it there and re-run `xcodegen generate`, never
   edit `ios/Bazar.xcodeproj` by hand.
3. Confirm the backend the build points at is deployed. The app talks to one GraphQL endpoint, so
   a schema the shipped binary does not know about is a broken release — regenerate and rebuild
   (`bun run generate:graphql`, `bun run generate:ios`) if the schema moved since the last upload.
   The deploy also rebuilds `server/system/changelog-content.ts` from `CHANGELOG.fr.md`; **without
   that deploy the in-app "Nouveautés" list stays stale**, since it is served by the backend.
4. Archive, export, upload:

   ```bash
   DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
     -project ios/Bazar.xcodeproj -scheme Bazar \
     -destination 'generic/platform=iOS' \
     -archivePath build/Bazar.xcarchive archive
   ```

   then `-exportArchive` with the App Store export options, and upload through Xcode Organizer or
   `xcrun altool`.

The store's "What's New" field is the same list, in French:
`bun scripts/release-notes.ts notes <version>` prints the bullets flat, headings and emphasis
stripped, because the store shows one plain list and would print `###` literally.

## Beta-macOS build machines

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
a non-beta macOS — no patch needed.
