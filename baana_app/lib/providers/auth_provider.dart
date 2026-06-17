import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String _currentPhone = '';
  String _currentName = 'Khalil'; // Valeur par défaut pour l'UI
  
  bool get isLoading => _isLoading;
  String get currentPhone => _currentPhone;
  String get currentName => _currentName;

  /// Inscription (demande de code OTP)
  Future<String?> register(String phone, String name) async {
    _setLoading(true);
    try {
      await _authService.register(phone, name);
      _currentPhone = phone; // On sauvegarde le téléphone pour l'écran OTP
      _currentName = name.isNotEmpty ? name : 'Khalil'; // Sauvegarde du nom
      return null; // Succès
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Vérification de l'OTP
  Future<String?> verifyOtp(String otpCode) async {
    _setLoading(true);
    try {
      await _authService.verifyOtp(_currentPhone, otpCode);
      return null; // Succès
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
