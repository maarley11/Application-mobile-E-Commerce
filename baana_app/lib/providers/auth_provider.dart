import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String _currentPhone = '';
  String _currentName = ''; 
  
  // Nouveaux champs CDC
  String _role = 'visitor'; // 'visitor', 'pro', 'admin'
  String _businessName = '';
  String _ninea = '';
  String _address = '';
  
  bool _isPro = false;
  String _proPlan = ''; // 'hebdo' ou 'mensuel'
  DateTime? _proExpirationDate;
  
  int _freeDeliveriesUsed = 0;
  final int _freeDeliveriesMax = 3;
  int _loyaltyPoints = 0;
  
  bool get isLoading => _isLoading;
  String get currentPhone => _currentPhone;
  String get currentName => _currentName.isNotEmpty ? _currentName : 'Client';
  String get role => _role;
  String get businessName => _businessName;
  String get ninea => _ninea;
  String get address => _address;
  bool get isPro => _isPro;
  String get proPlan => _proPlan;
  DateTime? get proExpirationDate => _proExpirationDate;
  int get freeDeliveriesLeft => isPro ? (_freeDeliveriesMax - _freeDeliveriesUsed) : 0;
  int get loyaltyPoints => _loyaltyPoints;

  Future<void> completeBusinessProfile(String businessName, String ninea, String address) async {
    _setLoading(true);
    try {
      await _authService.updateBusinessProfile(businessName: businessName, ninea: ninea, address: address);
      _businessName = businessName;
      _ninea = ninea;
      _address = address;
      _role = 'pro'; // Devient un pro/commerçant
      notifyListeners();
    } catch (e) {
      // Gérer l'erreur (ex: l'afficher)
      debugPrint('Erreur BusinessProfile: $e');
    } finally {
      _setLoading(false);
    }
  }

  void decrementFreeDelivery() {
    if (isPro && _freeDeliveriesUsed < _freeDeliveriesMax) {
      _freeDeliveriesUsed++;
      notifyListeners();
    }
  }

  /// Inscription (demande de code OTP)
  Future<String?> register(String phone, String name, String businessName, String ninea, String address) async {
    _setLoading(true);
    try {
      await _authService.register(phone, name);
      _currentPhone = phone; // On sauvegarde le téléphone pour l'écran OTP
      _currentName = name.isNotEmpty ? name : 'Client'; // Sauvegarde du nom
      
      // Stockage temporaire du profil entreprise pour le soumettre après OTP
      _businessName = businessName;
      _ninea = ninea;
      _address = address;
      
      return null; // Succès
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Connexion (demande de code OTP)
  Future<String?> login(String phone) async {
    _setLoading(true);
    try {
      await _authService.login(phone);
      _currentPhone = phone; // On sauvegarde le téléphone pour l'écran OTP
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
      final user = await _authService.verifyOtp(_currentPhone, otpCode);
      
      // Mettre à jour l'état avec les données du serveur
      if (user['name'] != null) _currentName = user['name'];
      _isPro = user['isPro'] ?? false;
      _role = user['role'] ?? (_isPro ? 'pro' : 'visitor');
      if (user['businessName'] != null) _businessName = user['businessName'];
      if (user['ninea'] != null) _ninea = user['ninea'];
      if (user['address'] != null) _address = user['address'];
      if (user['loyaltyPoints'] != null) _loyaltyPoints = user['loyaltyPoints'];
      
      // Si on vient de s'inscrire, on soumet le profil entreprise
      if (_businessName.isNotEmpty || _address.isNotEmpty) {
        try {
          await _authService.updateBusinessProfile(
            businessName: _businessName,
            ninea: _ninea,
            address: _address,
          );
          _role = 'pro'; // Devient un pro/commerçant
        } catch (e) {
          debugPrint('Erreur updateBusinessProfile après OTP: $e');
        }
      }
      
      notifyListeners();
      return null; // Succès
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Vérifie si l'utilisateur est déjà connecté au lancement
  Future<bool> checkAuthStatus() async {
    try {
      final token = await _authService.getToken();
      if (token != null && token.isNotEmpty) {
        // Idéalement, on appellerait un endpoint GET /api/users/me 
        // pour recharger les infos (nom, isPro, loyaltyPoints).
        // Comme on a le token, on considère qu'il est connecté.
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Récupère le profil complet de l'utilisateur (dont les points de fidélité)
  Future<void> fetchProfile() async {
    try {
      final response = await apiClient.client.get('/users/profile');
      final user = response.data['user'];
      if (user != null) {
        _loyaltyPoints = user['loyaltyPoints'] ?? 0;
        _isPro = user['isPro'] ?? false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur fetchProfile: \$e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Activer l'abonnement Pro
  Future<void> activateSubscription(String plan) async {
    _setLoading(true);
    try {
      await _authService.renewSubscription(plan);
      _isPro = true;
      _proPlan = plan;
      if (plan.toLowerCase() == 'hebdo') {
        _proExpirationDate = DateTime.now().add(const Duration(days: 7));
      } else {
        _proExpirationDate = DateTime.now().add(const Duration(days: 30));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur activateSubscription: $e');
      throw e;
    } finally {
      _setLoading(false);
    }
  }
}
