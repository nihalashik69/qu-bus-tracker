/// Google Maps JavaScript API loader (shared API).
///
/// Android and iOS get their Maps key from the native manifest
/// (`AndroidManifest.xml` / `Info.plist`), so the map always works there.
/// Flutter **web** instead needs the Maps JavaScript API pulled in from
/// `index.html` — historically via a `__GOOGLE_MAPS_API_KEY__` placeholder
/// that only the Vercel build script replaced.
///
/// That made web fragile: a plain `flutter build web`, a ZIP upload, GitHub
/// Pages or a drag-and-drop deploy shipped `key=__GOOGLE_MAPS_API_KEY__`,
/// the map silently failed, and because every live-bus ETA popup hangs off a
/// map marker, the ETA UI never appeared while the Android build was fine.
///
/// This loader removes the dependency on the deploy pipeline: the key is
/// compiled into the bundle with `--dart-define=GOOGLE_MAPS_API_KEY=...`
/// (defaulting to the key already committed for Android/iOS) and the script
/// is injected at runtime when `index.html` did not already load it.
///
/// Platform dispatch lives in `google_maps_web_loader_stub.dart`
/// (everything except web) and `google_maps_web_loader_web.dart` (web).
library;

import 'package:flutter/foundation.dart';

import 'google_maps_web_loader_stub.dart'
    if (dart.library.js_interop) 'google_maps_web_loader_web.dart' as impl;

/// Outcome of [GoogleMapsWebLoader.ensureLoaded].
enum GoogleMapsLoadStatus {
  /// Not a web build — the native Maps SDK handles everything.
  notWeb,

  /// The API was already present (loaded by `index.html`).
  alreadyLoaded,

  /// The API was injected and is ready.
  loaded,

  /// No key was available to inject.
  missingKey,

  /// Google rejected the key for this origin (`gm_authFailure`).
  authFailed,

  /// The script never became ready within the timeout.
  failed,
}

class GoogleMapsWebLoader {
  GoogleMapsWebLoader._();

  /// Key compiled in with `--dart-define=GOOGLE_MAPS_API_KEY=...`.
  ///
  /// Defaults to the key used by the Android/iOS builds so that any build
  /// path (`flutter build web`, Vercel, static hosting) produces a working
  /// map without extra configuration.
  static const String webApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyB9cEejKh6ckGq0BXgaxDt4bYaXgc8mEAA',
  );

  /// Live status, so screens can explain *why* the map is missing.
  static final ValueNotifier<GoogleMapsLoadStatus> status =
      ValueNotifier<GoogleMapsLoadStatus>(GoogleMapsLoadStatus.notWeb);

  /// True when the map cannot work on this platform.
  static bool get isUnavailable =>
      kIsWeb &&
      status.value != GoogleMapsLoadStatus.loaded &&
      status.value != GoogleMapsLoadStatus.alreadyLoaded;

  /// Human-readable, actionable hint for the map placeholder UI.
  static String get failureHint {
    switch (status.value) {
      case GoogleMapsLoadStatus.missingKey:
        return 'No Google Maps API key was baked into this web build. '
            'Rebuild with --dart-define=GOOGLE_MAPS_API_KEY=<browser key>.';
      case GoogleMapsLoadStatus.authFailed:
        return 'Google Maps rejected the API key for this website. In Google '
            'Cloud Console enable "Maps JavaScript API" for the key and remove '
            'HTTP referrer restrictions (or add this domain).';
      case GoogleMapsLoadStatus.failed:
      case GoogleMapsLoadStatus.notWeb:
      case GoogleMapsLoadStatus.loaded:
      case GoogleMapsLoadStatus.alreadyLoaded:
        return 'The Google Maps JavaScript API did not load for this website. '
            'Check the browser console for the exact Maps error.';
    }
  }

  /// Makes sure `google.maps` exists before the first `GoogleMap` is built.
  ///
  /// Safe to call on every platform; it is a no-op off the web.
  static Future<GoogleMapsLoadStatus> ensureLoaded() async {
    final result = await impl.ensureLoaded();
    status.value = result;
    return result;
  }
}
