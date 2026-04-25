# Firebase + Apollo iOS — manual Xcode setup

The migration to a Firebase backend requires a few one-time Xcode steps that
can't be expressed in source files. Do these once in Xcode, then everything
else (Auth flow, GraphQL client, codegen, feature refactors) is in code.

## 1. Add Swift Package Manager dependencies

`File → Add Package Dependencies…`

| URL | Product(s) | Min version |
| --- | --- | --- |
| `https://github.com/apollographql/apollo-ios.git` | `Apollo`, `ApolloAPI` | 1.18.0 |
| `https://github.com/firebase/firebase-ios-sdk.git` | `FirebaseCore`, `FirebaseAuth` | 11.0.0 |

Both attached to the `Bazar` target.

## 2. Capabilities

`Target Bazar → Signing & Capabilities → + Capability`

- **Sign in with Apple** — required for Apple Sign-In to work with Firebase Auth.

## 3. GoogleService-Info.plist

The `terraform apply` step generates this file at `ios/Bazar/GoogleService-Info.plist`
(see `infra/ios.tf`). The file is gitignored — every developer downloads
their own copy via `make bootstrap` against their GCP project.

In Xcode, drag-and-drop the file into the `Bazar` group so it gets added to
the bundle (`Copy items if needed: yes`, `Targets: Bazar`).

## 4. Apple Developer prerequisites (one-time)

In `https://developer.apple.com/account`:

1. Create a Services ID for the Bazar app (e.g. `co.polyforms.bazar.signin`).
2. Configure Sign in with Apple, with the bundle id `co.polyforms.bazar` as
   primary App ID. Add the return URL displayed by Firebase Identity Platform
   (`https://<project>.firebaseapp.com/__/auth/handler`).
3. Generate an Apple key (.p8) with Sign in with Apple enabled. Save the
   Team ID, Services ID, Key ID, and `.p8` file — they go into
   `infra/terraform.tfvars` for the bootstrap.

## 5. Apollo iOS codegen

1. Install once globally:
   ```bash
   brew install apollo-ios-cli
   ```
2. Whenever the GraphQL schema or any operation changes, regenerate:
   ```bash
   # from repo root: regenerate the schema SDL first
   bun run generate:graphql
   # then run the iOS codegen
   cd ios && apollo-ios-cli generate
   ```
3. Optional: add an Xcode build phase named "Generate GraphQL" that runs
   `apollo-ios-cli generate` on each build.

## 6. Update SharedConfig.defaultServerURL

After `make bootstrap` prints the Cloud Function URL, replace the
`PLACEHOLDER` in `ios/Bazar/Shared/SharedConfig.swift` with that URL (or
override it via UserDefaults["serverURL"] at runtime).

## 7. Notes on removed features

- The old `Secrets.swift` `apiToken` field is gone. Auth now uses Firebase
  ID tokens injected by `FirebaseTokenInterceptor`.
- The old user-tag chooser and dev/prod environment toggle in
  `Settings.bundle/Root.plist` are obsolete — keep them only if you need a
  per-build server URL override.
- The image upload domain has been removed server-side. Any iOS code that
  references item photos (`photoImageId`, `invoiceImageId`, `photoBase64`,
  `invoiceImageBase64`, `previewImageBase64`) needs to be removed manually
  after you regenerate the Apollo types in step 5.
