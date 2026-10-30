import 'package:geolocator/geolocator.dart';

enum LocationFailure {
  servicesDisabled,
  denied,
  deniedForever,
  unavailable,
}

class LocationException implements Exception {
  const LocationException(this.failure);

  final LocationFailure failure;

  @override
  String toString() => 'LocationException($failure)';
}

/// Reads the device GPS position (with permission handling).
class LocationService {
  Future<Position> currentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationException(LocationFailure.servicesDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(LocationFailure.denied);
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(LocationFailure.deniedForever);
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 20),
        ),
      );
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
      throw const LocationException(LocationFailure.unavailable);
    }
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
