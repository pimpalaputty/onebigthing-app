#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
PUBLIC_DIR="${ROOT_DIR}/public"
TMP_DIR="$(mktemp -d)"

FLUTTER_VERSION="${FLUTTER_VERSION:-3.24.4}"
FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/linux/${FLUTTER_ARCHIVE}"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

echo "Downloading Flutter SDK (${FLUTTER_VERSION}-${FLUTTER_CHANNEL})..."
curl -fL --retry 3 --retry-delay 2 "${FLUTTER_URL}" -o "${TMP_DIR}/flutter-sdk.tar.xz"

echo "Extracting Flutter SDK..."
tar -C "${TMP_DIR}" -xf "${TMP_DIR}/flutter-sdk.tar.xz"
export PATH="${TMP_DIR}/flutter/bin:${PATH}"

echo "Disabling Flutter analytics..."
flutter config --no-analytics >/dev/null

echo "Checking Flutter environment..."
flutter doctor -v

if [ -d "${BUILD_DIR}" ]; then
  echo "Cleaning existing build artifacts..."
  rm -rf "${BUILD_DIR}"
fi

echo "Fetching Dart and Flutter dependencies..."
flutter pub get

echo "Building Flutter web release bundle..."
flutter build web --release --web-renderer auto

echo "Preparing public directory..."
rm -rf "${PUBLIC_DIR}"
mkdir -p "${PUBLIC_DIR}"
cp -R "${BUILD_DIR}/web/." "${PUBLIC_DIR}/"

echo "Flutter web bundle copied to public/."

