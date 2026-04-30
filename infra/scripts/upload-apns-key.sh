#!/usr/bin/env bash
# Upload an APNs Authentication Key to Firebase Cloud Messaging for the iOS
# app. Uses the Firebase mobilesdk-pa private API: the Firebase Console hits
# the same endpoint, but Google has not exposed it as a public REST API or
# Terraform resource. Treat as best-effort — fall back to the Firebase
# Console UI if this script ever stops working (see infra/README.md).
#
# Usage: upload-apns-key.sh <project_id> <ios_app_id> <key_id> <team_id> <p8_path>

set -euo pipefail

PROJECT_ID="${1:?project_id required}"
APP_ID="${2:?ios_app_id required}"
KEY_ID="${3:?key_id required}"
TEAM_ID="${4:?team_id required}"
P8_PATH="${5:?p8_path required}"

if [[ ! -f "$P8_PATH" ]]; then
  echo "[apns] missing key file: $P8_PATH" >&2
  exit 1
fi

if ! command -v gcloud >/dev/null; then
  echo "[apns] gcloud CLI not found in PATH" >&2
  exit 1
fi

ACCESS_TOKEN="$(gcloud auth print-access-token)"
PROJECT_NUMBER="$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')"

# Read the .p8 contents into a JSON-safe payload.
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
echo "[apns] FALLBACK: upload manually via Firebase Console →" >&2
echo "  Project Settings → Cloud Messaging → Apple app configuration →" >&2
echo "  APNs Authentication Key → Upload (use ${P8_PATH}, key id ${KEY_ID})." >&2
echo "[apns] continuing terraform apply; runtime FCM sends will fail until the key is set." >&2
exit 0
