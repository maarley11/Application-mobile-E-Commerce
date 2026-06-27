import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal();

  /// Demande l'envoi d'un OTP pour inscription
  Future<void> register(String phone, String name) async {
    try {
      await apiClient.client.post('/auth/register', data: {
        'phone': phone,
        'name': name,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Demande l'envoi d'un OTP pour connexion
  Future<void> login(String phone) async {
    try {
      await apiClient.client.post('/auth/login', data: {
        'phone': phone,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Vérifie l'OTP et stocke le JWT
  Future<Map<String, dynamic>> verifyOtp(String phone, String otpCode) async {
    try {
      final response = await apiClient.client.post('/auth/verify-otp', data: {
        'phone': phone,
        'otpCode': otpCode,
      });

      final token = response.data['token'];
      if (token != null) {
        await apiClient.saveToken(token);
      }
      return response.data['user'];
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Met à jour le profil entreprise
  Future<void> updateBusinessProfile({required String businessName, required String ninea, required String address}) async {
    try {
      await apiClient.client.put('/users/profile', data: {
        'businessName': businessName,
        'ninea': ninea,
        'address': address,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Renouvellement d'abonnement PRO
  Future<void> renewSubscription(String plan) async {
    try {
      await apiClient.client.post('/subscriptions/renew', data: {
        'plan': plan, // 'hebdo' ou 'mensuel'
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le token actuel
  Future<String?> getToken() async {
    return await apiClient.getToken();
  }

  /// Déconnecte l'utilisateur
  Future<void> logout() async {
    await apiClient.clearToken();
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.statusCode == 400) {
        return error.response?.data['message'] ?? 'Données invalides';
      } else if (error.response?.statusCode == 401) {
        return 'Code OTP incorrect ou expiré';
      }
      return 'Erreur de connexion au serveur';
    }
    return 'Une erreur inattendue est survenue';
  }
}
