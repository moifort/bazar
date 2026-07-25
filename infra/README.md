# Bazar — Terraform infrastructure

This module provisions the entire Firebase stack for Bazar from a greenfield
GCP project: project itself, Firebase enablement, Firestore (Native),
security rules + indexes, Identity Platform with Apple OAuth, the iOS
Firebase app (and downloads `GoogleService-Info.plist`), the secrets in
Secret Manager, and the Cloud Function Gen 2 that runs the Nitro/GraphQL
backend.

## Prerequisites

- `gcloud` CLI authenticated with Application Default Credentials:
  `gcloud auth application-default login`
- `bun` (used by the `bootstrap.sh` driver to build the Nitro bundle)
- An Apple Developer account with a Service ID and a `.p8` private key
  (Sign in with Apple). See `ios/FIREBASE_SETUP.md` for the exact steps.
- A GCP billing account id and either an `org_id` or `folder_id`.

`terraform` is auto-installed into `infra/.bin/` by `scripts/install-terraform.sh`.

## One-time bootstrap

```bash
cp infra/terraform.tfvars.example infra/terraform.tfvars
# Edit terraform.tfvars: project_id, billing, Apple, secrets
cp ~/Downloads/AuthKey_KEY1234567.p8 infra/

# From repo root
bun run bootstrap
```

The `bootstrap.sh` driver:

1. validates prerequisites,
2. runs `bun install + bun run generate:graphql + bun run build`,
3. runs `terraform init && terraform apply -auto-approve`,
4. POSTs `/admin/migrate` with the generated admin token,
5. prints the Cloud Function URL and the iOS plist path.

End state after a fresh bootstrap: backend operational, Firestore ready,
Apple Sign-In configured, `ios/Bazar/GoogleService-Info.plist` written.

## Subsequent deploys (CI)

Every push to `main` runs `.github/workflows/deploy.yml`, which builds the
Nitro bundle and runs `terraform apply` against the same state stored in
GCS. Only the function source archive changes between runs.

## Cloud Messaging (FCM)

Push notifications to iOS go through Firebase Cloud Messaging (FCM), which
in turn forwards to APNs. Two pieces of state are needed:

1. **APIs enabled** (`fcm.googleapis.com`, `fcmregistrations.googleapis.com`)
   — declared in `project.tf`.
2. **APNs Authentication Key uploaded** to Firebase Cloud Messaging.

The same Apple `.p8` used for Sign in with Apple is reused by default
(`apns_key_id` / `apns_private_key_path` default to `apple_*` values). The
key must have the **APNs** capability enabled in Apple Developer (in
addition to *Sign in with Apple*). If only one key is needed and it has
both capabilities, no extra config is required.

`messaging.tf` runs `scripts/upload-apns-key.sh` via a `null_resource` to
upload the key automatically. The endpoint it calls
(`firebasemobilesdk-pa.googleapis.com/v1/projects/.../clients/{app}:setApnsAuthKey`)
is the same one used by the Firebase Console but is not part of the
publicly documented Firebase Management API. If Google changes it, the
script logs the failure and continues — terraform `apply` succeeds — and
you can finish the upload in the UI:

> Firebase Console → Project Settings → Cloud Messaging → Apple app
> configuration → APNs Authentication Key → Upload.

The runtime service account `bazar-runtime` is granted
`roles/firebasecloudmessaging.admin` so the Cloud Function can call the
FCM v1 send API with Application Default Credentials.

## Day-to-day

Every entry point is a `bun run` script — there is no Makefile.

| Script | What it does |
| --- | --- |
| `bun run bootstrap` | One-shot provisioning of a fresh project (`scripts/bootstrap.sh`) |
| `bun run infra:build` | Install, `nitro prepare`, export the SDL, build the function bundle |
| `bun run infra:init` | `terraform init` in `infra/` |
| `bun run infra:plan` | Build, then `terraform plan` |
| `bun run infra:apply` | Build, then `terraform apply` |
| `bun run destroy` | Tear the whole stack down (`scripts/teardown.sh`) |

`plan` and `apply` rebuild first on purpose: the function source archive is an
input to the plan, so planning against a stale bundle plans the wrong deploy.

## Teardown

```bash
bun run destroy
```
