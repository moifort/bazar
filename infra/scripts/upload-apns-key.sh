#!/usr/bin/env bash
# Upload an APNs Authentication Key to Firebase Cloud Messaging for the iOS
# app. Uses the Firebase mobilesdk-pa private API: the Firebase Console hits
# the same endpoint, but Google has not exposed it as a public REST API or
# Terraform resource. Treat as best-effort — fall back to the Firebase
# Console UI if this script ever stops working (see infra/README.md).
#
# Usage: upload-apns-key.sh <project_id> <project_number> <ios_app_id> <key_id> <team_id> <p8_path>

set -uo pipefail

PROJECT_ID="${1:?project_id required}"
PROJECT_NUMBER="${2:?project_number required}"
APP_ID="${3:?ios_app_id required}"
KEY_ID="${4:?key_id required}"
TEAM_ID="${5:?team_id required}"
P8_PATH="${6:?p8_path required}"

manual_fallback() {
  echo "[apns] FALLBACK: upload manually via Firebase Console →" >&2
  echo "  Project Settings → Cloud Messaging → Apple app configuration →" >&2
  echo "  APNs Authentication Key → Upload (use ${P8_PATH}, key id ${KEY_ID})." >&2
  echo "[apns] continuing terraform apply; runtime FCM sends will fail until the key is set." >&2
  exit 0
}

if [[ ! -f "$P8_PATH" ]]; then
  echo "[apns] missing key file: $P8_PATH" >&2
  manual_fallback
fi

if ! command -v gcloud >/dev/null; then
  echo "[apns] gcloud CLI not found in PATH" >&2
  manual_fallback
fi

# Use ADC (`gcloud auth application-default login`) — same auth Terraform uses.
ACCESS_TOKEN="$(gcloud auth application-default print-access-token 2>/dev/null)"
if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "[apns] could not obtain ADC access token (run 'gcloud auth application-default login')" >&2
  manual_fallback
fi

# Escape newlines in the .p8 so it's a valid JSON string.
PRIVATE_KEY="$(awk '{printf "%s\\n", $0}' "$P8_PATH")"

ENDPOINT="https://firebasemobilesdk-pa.googleapis.com/v1/projects/${PROJECT_NUMBER}/clients/${APP_ID}:setApnsAuthKey"

PAYLOAD=$(cat <<JSON
{
  "keyId": "${KEY_ID}",
  "teamId": "${TEAM_ID}",
  "privateKey": "${PRIVATE_KEY}"
}
JSON
)

HTTP_CODE=$(curl -sS -o /tmp/apns-upload.out -w "%{http_code}" \
  -X POST "$ENDPOINT" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  --data "$PAYLOAD" || echo "000")

if [[ "$HTTP_CODE" =~ ^2 ]]; then
  echo "[apns] uploaded auth key ${KEY_ID} for app ${APP_ID}"
  exit 0
fi

echo "[apns] upload failed (HTTP $HTTP_CODE). Response:" >&2
cat /tmp/apns-upload.out >&2 || true
echo >&2
manual_fallback
