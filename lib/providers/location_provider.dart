// providers/location_provider.dart
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _error = 'Los servicios de ubicación están desactivados';
      notifyListeners();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _error = 'Permisos de ubicación denegados';
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _error = 'Los permisos de ubicación están permanentemente denegados';
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool hasPermission = await checkPermission();
      if (!hasPermission) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _getAddressFromCoordinates();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al obtener la ubicación: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getAddressFromCoordinates() async {
    if (_currentPosition == null) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentAddress = '${place.street}, ${place.locality}';
      }
    } catch (e) {
      _currentAddress = 'Ubicación actual';
    }
  }

  void setManualLocation(double lat, double lon, String address) {
    _currentPosition = Position(
      latitude: lat,
      longitude: lon,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
    _currentAddress = address;
    notifyListeners();
  }
}
