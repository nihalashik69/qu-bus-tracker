/// Non-web implementation of [ensureLoaded] — nothing to do.
///
/// Android and iOS read the Maps key from the native manifest, so the map
/// is ready without any JavaScript. See `google_maps_web_loader.dart`.
library;

import 'google_maps_web_loader.dart';

Future<GoogleMapsLoadStatus> ensureLoaded() async {
  return GoogleMapsLoadStatus.notWeb;
}
