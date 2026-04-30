# Firebase Cloud Messaging (FCM) wiring.
#
# - Enable the FCM APIs (already done in project.tf).
# - Grant the runtime service account permission to send messages via FCM v1.
# - Best-effort upload of the APNs Authentication Key to Firebase Cloud
#   Messaging via the (currently undocumented) Firebase mobilesdk-pa private
#   API. If the API rejects the call (e.g. it has changed), the upload must
#   be performed once via Firebase Console — see infra/README.md.

locals {
  apns_key_id           = coalesce(var.apns_key_id, var.apple_key_id)
  apns_private_key_path = coalesce(var.apns_private_key_path, var.apple_private_key_path)
}

# Read the project number — needed by the Firebase mobilesdk-pa endpoint and
# saves the upload script from making a separate `gcloud projects describe`
# call (which would require an interactive gcloud auth login).
data "google_project" "this" {
  project_id = google_project.this.project_id
}

# Allow the Cloud Function runtime SA to call the FCM HTTP v1 API.
resource "google_project_iam_member" "function_fcm" {
  project = google_project.this.project_id
  role    = "roles/firebasecloudmessaging.admin"
  member  = "serviceAccount:${google_service_account.function.email}"

  depends_on = [google_project_service.apis]
}

# Re-run the upload script when any of the APNs inputs change. We hash the
# .p8 file so a key rotation triggers a re-upload, plus the key id and the
# Firebase iOS app id (which the API needs as a target).
resource "null_resource" "apns_auth_key" {
  triggers = {
    apns_key_id = local.apns_key_id
    p8_sha256   = filesha256(local.apns_private_key_path)
    ios_app_id  = google_firebase_apple_app.ios.app_id
    team_id     = var.apple_team_id
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      ${path.module}/scripts/upload-apns-key.sh \
        '${google_project.this.project_id}' \
        '${data.google_project.this.number}' \
        '${google_firebase_apple_app.ios.app_id}' \
        '${local.apns_key_id}' \
        '${var.apple_team_id}' \
        '${local.apns_private_key_path}'
    EOT
  }

  depends_on = [
    google_project_service.apis,
    google_firebase_apple_app.ios,
  ]
}
