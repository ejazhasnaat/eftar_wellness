// lib/shared/services/location_service.dart
import 'dart:async';
import 'package:geocoding/geocoding.dart' as gc;
import 'package:geolocator/geolocator.dart';

class CityCountry {
  final String? city;
  final String? country;
  final String? isoCountryCode;
  CityCountry({this.city, this.country, this.isoCountryCode});
}

class LocationService {
  /// Attempts to get city & country within [timeout]. Returns null on any failure.
  static Future<CityCountry?> getCityCountry({Duration timeout = const Duration(seconds: 8)}) async {
    try {
      // 1) Permissions
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        return null; // Respect user choice
      }

      // 2) Ensure service enabled (mobile)
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      // 3) Get rough position quickly (balanced)
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // city-level is enough
        timeLimit: timeout,
      );

      // 4) Reverse geocode
      final placemarks = await gc.placemarkFromCoordinates(pos.latitude, pos.longitude)
          .timeout(const Duration(seconds: 6), onTimeout: () => <gc.Placemark>[]);

      if (placemarks.isEmpty) return null;
      final p = placemarks.first;

      // City can be in locality/subAdministrativeArea depending on country
      final city = (p.locality?.trim().isNotEmpty ?? false)
          ? p.locality!.trim()
          : (p.subAdministrativeArea?.trim().isNotEmpty ?? false)
              ? p.subAdministrativeArea!.trim()
              : null;

      final country = p.country?.trim();
      final iso = p.isoCountryCode?.trim();

      if ((city == null || city.isEmpty) && (country == null || country.isEmpty)) {
        return null;
      }
      return CityCountry(city: city, country: country, isoCountryCode: iso);
    } catch (_) {
      return null; // Fail-safe: never throw into UI
    }
  }
}

