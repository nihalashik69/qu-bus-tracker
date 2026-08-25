/// Location service helpers
///
/// Lightweight utilities that wrap `geolocator` to request permissions,
/// obtain the current device location, and expose helper methods that the
/// UI can call without dealing with low-level platform details.
///
library;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  /// Check if location permissions are granted
  static Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Request location permissions
  static Future<bool> requestLocationPermission() async {
    if (kIsWeb && Uri.base.scheme != 'https' && Uri.base.host != 'localhost') {
      debugPrint('Location permission requires HTTPS (except localhost).');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Get current location
  static Future<LatLng?> getCurrentLocation() async {
    try {
      if (kIsWeb && Uri.base.scheme != 'https' && Uri.base.host != 'localhost') {
        debugPrint('Location access requires HTTPS (except localhost).');
        return null;
      }

      if (!await hasLocationPermission()) {
        bool granted = await requestLocationPermission();
        if (!granted) {
          debugPrint('Location permission was not granted.');
          return null;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }
}

