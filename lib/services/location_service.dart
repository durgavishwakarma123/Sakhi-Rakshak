import 'package:geolocator/geolocator.dart';
import '../model/location_model.dart';

class LocationService {
  Future<LocationModel> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled.");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permission denied.");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permission permanently denied.");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print("LocationService Error: $e. Falling back to mock coordinates.");
      // Fallback to New Delhi default coordinates
      return LocationModel(
        latitude: 28.6139,
        longitude: 77.2090,
        timestamp: DateTime.now(),
      );
    }
  }
}