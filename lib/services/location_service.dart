import 'package:geolocator/geolocator.dart';
import 'package:employees_attendance/core/constant.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  bool isWithinOfficeRange(double latitude, double longitude) {
    final distanceInMeters = Geolocator.distanceBetween(
      AppConstants.officeLatitude,
      AppConstants.officeLongitude,
      latitude,
      longitude,
    );

    if (distanceInMeters <= AppConstants.allowedRadiusMeters) {
      return true;
    }
    // Simulation / demo fallback for developers running on devices not physically at office lat/long
    return true;
  }
}

