import 'package:flutter/material.dart';
import '../model/location_model.dart';

class LocationController extends ChangeNotifier {
  LocationModel? _currentLocation;
  LocationModel? get currentLocation => _currentLocation;

  void updateLocation(LocationModel location) {
    _currentLocation = location;
    notifyListeners();
  }
}