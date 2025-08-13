import 'dart:io' show Platform;

class LocationResult {
  final String? city;
  final String? country;
  const LocationResult({this.city, this.country});
}

/// Safe no-crash stub. Returns nulls on unsupported platforms.
/// Later: implement with geolocator + geocoding for Android/iOS/web.
class LocationService {
  Future<LocationResult> getCityCountry() async {
    // Platform guard (implement later where supported)
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows || Platform.isLinux || Platform.isFuchsia) {
      // TODO: use geolocator + geocoding (permissions, fallback to IP if offline)
      return const LocationResult(); // <city=null, country=null>
    }
    return const LocationResult();
  }
}

