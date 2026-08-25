#!/usr/bin/env bash
set -euo pipefail

flutter_version="${FLUTTER_VERSION:-3.32.4}"
flutter_root="${HOME}/.cache/flutter-sdk-${flutter_version}"

if [[ ! -x "${flutter_root}/bin/flutter" ]]; then
  mkdir -p "${HOME}/.cache"
  archive="${HOME}/.cache/flutter_linux_${flutter_version}-stable.tar.xz"
  curl --fail --location --retry 3 \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${flutter_version}-stable.tar.xz" \
    --output "${archive}"
  tar -xJf "${archive}" -C "${HOME}/.cache"
  mv "${HOME}/.cache/flutter" "${flutter_root}"
fi

export PATH="${flutter_root}/bin:${PATH}"
export CI=true
git config --global --add safe.directory "${flutter_root}"

: "${CONVEX_URL:?Set CONVEX_URL in Vercel Project Settings}"
: "${GOOGLE_MAPS_API_KEY:?Set GOOGLE_MAPS_API_KEY in Vercel Project Settings}"

flutter config --no-analytics
flutter pub get
flutter build web --release --dart-define="CONVEX_URL=${CONVEX_URL}"

sed -i "s/__GOOGLE_MAPS_API_KEY__/${GOOGLE_MAPS_API_KEY}/g" build/web/index.html