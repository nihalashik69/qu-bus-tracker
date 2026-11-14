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

# Browser-restricted Maps JavaScript API key. It is substituted into
# index.html *and* compiled into the bundle (lib/google_maps_web_loader.dart)
# so that the map - and every live-bus ETA popup - works even if a deploy path
# forgets the substitution. When it is unset we simply omit the dart-define and
# the key compiled into the Dart source is used.
maps_key="${GOOGLE_MAPS_API_KEY:-}"
if [[ -z "${maps_key}" ]]; then
  echo "WARNING: GOOGLE_MAPS_API_KEY is not set; using the key compiled into the Dart source." >&2
fi

dart_defines=(--dart-define="CONVEX_URL=${CONVEX_URL}")
if [[ -n "${maps_key}" ]]; then
  dart_defines+=(--dart-define="GOOGLE_MAPS_API_KEY=${maps_key}")
fi

flutter config --no-analytics
flutter pub get
flutter build web --release "${dart_defines[@]}"

if [[ -n "${maps_key}" ]]; then
  sed -i "s/__GOOGLE_MAPS_API_KEY__/${maps_key}/g" build/web/index.html
  if grep -q "__GOOGLE_MAPS_API_KEY__" build/web/index.html; then
    echo "ERROR: the Google Maps key placeholder survived the build." >&2
    exit 1
  fi
fi

echo "Web build ready. CONVEX_URL=${CONVEX_URL} maps_key_set=$([[ -n "${maps_key}" ]] && echo yes || echo no)"
