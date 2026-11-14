/// Web implementation of the Google Maps JavaScript API loader.
///
/// Injects `https://maps.googleapis.com/maps/api/js` when `index.html` did
/// not already do it (which is what happens on every build that does not run
/// the Vercel substitution script), then waits until `google.maps.Map` is
/// really available. See `google_maps_web_loader.dart` for the background.
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'google_maps_web_loader.dart';

const String _mapsScriptSelector =
    'script[src*="maps.googleapis.com/maps/api/js"]';

/// Google calls this global when it rejects the key, which is the failure
/// mode that silently killed the map (and therefore the ETA popups) on the
/// deployed website.
void _installAuthFailureHook() {
  web.window.setProperty(
    'gm_authFailure'.toJS,
    (() {
      GoogleMapsWebLoader.status.value = GoogleMapsLoadStatus.authFailed;
    }).toJS,
  );
}

bool _isDefined(JSAny? value) => value != null && !value.isUndefinedOrNull;

/// True once `google.maps.Map` exists, i.e. the API really loaded.
bool _apiReady() {
  final JSAny? google = web.window.getProperty('google'.toJS);
  if (!_isDefined(google)) return false;

  final JSAny? maps = (google! as JSObject).getProperty('maps'.toJS);
  if (!_isDefined(maps)) return false;

  return _isDefined((maps! as JSObject).getProperty('Map'.toJS));
}

bool _scriptAlreadyPresent() {
  return web.document.querySelectorAll(_mapsScriptSelector).length > 0;
}

void _injectScript(String key) {
  final script =
      web.document.createElement('script') as web.HTMLScriptElement;
  script.src =
      'https://maps.googleapis.com/maps/api/js?key=${Uri.encodeComponent(key)}';
  web.document.head?.appendChild(script);
}

Future<GoogleMapsLoadStatus> ensureLoaded() async {
  if (_apiReady()) {
    return GoogleMapsLoadStatus.alreadyLoaded;
  }

  _installAuthFailureHook();

  if (!_scriptAlreadyPresent()) {
    final key = GoogleMapsWebLoader.webApiKey;
    if (key.isEmpty) {
      return GoogleMapsLoadStatus.missingKey;
    }
    _injectScript(key);
  }

  final deadline = DateTime.now().add(const Duration(seconds: 12));
  while (DateTime.now().isBefore(deadline)) {
    if (_apiReady()) {
      return GoogleMapsLoadStatus.loaded;
    }
    if (GoogleMapsWebLoader.status.value == GoogleMapsLoadStatus.authFailed) {
      return GoogleMapsLoadStatus.authFailed;
    }
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  return GoogleMapsLoadStatus.failed;
}
