// providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    
    if (userId != null) {
      // Cargar usuario de la base de datos
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final user = await DatabaseService.instance.loginUser(email, password);
      
      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.id);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, String phone) async {
    try {
      final user = await DatabaseService.instance.createUser(
        email,
        password,
        name,
        phone,
      );
      
      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.id);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _isAuthenticated = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    
    notifyListeners();
  }

  Future<void> updateUserLocation(String address, double lat, double lon) async {
    if (_user != null) {
      await DatabaseService.instance.updateUserLocation(
        _user!.id,
        address,
        lat,
        lon,
      );
      
      _user = User(
        id: _user!.id,
        email: _user!.email,
        name: _user!.name,
        phone: _user!.phone,
        address: address,
        latitude: lat,
        longitude: lon,
      );
      
      notifyListeners();
    }
  }
}
