#!/usr/bin/env bash
# Regenerate the iOS app's typed GraphQL code from shared/schema.graphql.
#
# `apollo-ios-cli` is not installed system-wide: it ships inside the Apollo iOS
# package that SwiftPM checks out for the Xcode project, so its path depends on
# the DerivedData folder Xcode picked. Resolve it here rather than asking every
# caller to hunt for it — and pin it to *this* project's checkout, since another
# project's copy is likely a different, incompatible CLI version.
set -euo pipefail

cd "$(dirname "$0")/.."

checkout_cli() {
  # `|| true`: before the first resolve there is no Bazar-* DerivedData at all,
  # and under `set -o pipefail` find's failure would kill the script before the
  # explanatory message below ever runs.
  find ~/Library/Developer/Xcode/DerivedData/Bazar-*/SourcePackages/checkouts/apollo-ios/CLI \
    -name "$1" 2>/dev/null | head -1 || true
}

cli=$(checkout_cli apollo-ios-cli)

# SwiftPM checks the CLI out as a tarball; it is Xcode's build plugin that
# unpacks it, so after a bare `-resolvePackageDependencies` only the archive
# exists. Unpack it ourselves into a cache dir — the checkout is read-only —
# so codegen does not require a full iOS build first.
if [ -z "$cli" ]; then
  archive=$(checkout_cli apollo-ios-cli.tar.gz)
  if [ -n "$archive" ]; then
    cache="${TMPDIR:-/tmp}/bazar-apollo-cli"
    mkdir -p "$cache"
    tar -xzf "$archive" -C "$cache"
    cli="$cache/apollo-ios-cli"
  fi
fi

if [ -z "$cli" ]; then
  cli=$(command -v apollo-ios-cli || true)
fi

if [ -z "$cli" ]; then
  echo "apollo-ios-cli not found." >&2
  echo "Run this once so SwiftPM checks out apollo-ios, then retry:" >&2
  echo "  DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \\" >&2
  echo "    -project ios/Bazar.xcodeproj -scheme Bazar -resolvePackageDependencies" >&2
  exit 1
fi

echo "Using $cli"
cd ios && "$cli" generate
