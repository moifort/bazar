# Apple Sign-In Setup

How **Sign in with Apple** is wired for the Bazar iOS app (Firebase Auth / Identity Platform).
The infra is already in place and activates as soon as the values below are supplied — the work
happens in the **Apple Developer portal**, then three values plus one file are fed back into the
repo. The iOS side needs no changes.

## Fixed constants

Already set across the project — do not change them.

| Item | Value |
| ---- | ----- |
| Apple Team ID | `46C337T7YN` |
| App ID (bundle id) | `co.polyforms.bazar` |
| Services ID | `co.polyforms.bazar.signin` |
| Firebase / GCP project | `polyforms-bazar-prod` |
| Firebase auth domain | `polyforms-bazar-prod.firebaseapp.com` |
| OAuth return URL | `https://polyforms-bazar-prod.firebaseapp.com/__/auth/handler` |

## Apple Developer portal

In [developer.apple.com/account](https://developer.apple.com/account) under Team `46C337T7YN`:

1. **App ID** — Certificates, Identifiers & Profiles → Identifiers → App IDs.
   - Ensure the App ID `co.polyforms.bazar` exists (create it as type *App* otherwise).
   - Enable the **Sign In with Apple** capability (*Enable as a primary App ID*), then save.

2. **Services ID** — Identifiers → (filter *Services IDs*) → +.
   - Identifier `co.polyforms.bazar.signin`, description `Bazar Sign In`.
   - Check **Sign In with Apple**, then *Configure*:
     - **Primary App ID**: `co.polyforms.bazar`
     - **Domains and Subdomains**: `polyforms-bazar-prod.firebaseapp.com`
     - **Return URLs**: `https://polyforms-bazar-prod.firebaseapp.com/__/auth/handler`
   - Save / continue / register.

3. **Sign in with Apple key** — Keys → +.
   - Name `Bazar Sign In Key`.
   - Check **Sign In with Apple**, *Configure* → Primary App ID `co.polyforms.bazar`.
   - *Continue* → *Register* → **download the `.p8` file** (⚠️ downloadable **only once**).
   - Note the 10-character **Key ID** shown on the key's page.

## Deliverables

1. **Services ID** — `co.polyforms.bazar.signin` (created and configured).
2. **Key ID** — the 10-character identifier of the key.
3. **`.p8` file** — the downloaded `AuthKey_XXXXXXXXXX.p8`.
4. **Team ID** — `46C337T7YN` (already known).

## Repo wiring

1. Drop the `.p8` in `infra/` (the `AuthKey_*.p8` pattern is gitignored — **never commit a key**).
2. In `infra/terraform.tfvars`: set `apple_key_id = "<KEY_ID>"` and
   `apple_private_key_path = "./AuthKey_<KEY_ID>.p8"` (the other Apple fields are already correct).
3. GitHub secrets (repo `moifort/bazar`):
   - `APPLE_TEAM_ID` = `46C337T7YN`
   - `APPLE_SERVICES_ID` = `co.polyforms.bazar.signin`
   - `APPLE_KEY_ID` = `<KEY_ID>`
   - `APPLE_PRIVATE_KEY_P8` = the full text contents of the `.p8`
4. `terraform apply` (or a push to `main`) configures the Apple provider in Identity Platform —
   `infra/auth.tf` registers it as a default supported IdP, JSON-encoding the team id, key id and
   private key as the client secret.

## iOS app

Nothing to do: the `com.apple.developer.applesignin` entitlement and the
`SignInWithAppleButton → OAuthProvider.appleCredential` flow are already in place
(`ios/Bazar/Features/Auth/`, with `AppleNonce` producing the nonce Firebase requires).

## Push notifications use a different key

Sign in with Apple and APNs are two distinct Apple keys. The APNs key is uploaded to Firebase
Cloud Messaging by `infra/scripts/upload-apns-key.sh`; don't reuse one for the other.
