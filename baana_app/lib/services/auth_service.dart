import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';

  AuthService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _getBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Intercepteur pour injecter le token JWT automatiquement
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  String _getBaseUrl() {
    if (kIsWeb) return 'http://localhost:3000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    } catch (_) {}
    return 'http://localhost:3000/api';
  }

  /// Demande l'envoi d'un OTP
  Future<void> register(String phone, String name) async {
    try {
      await _dio.post('/auth/register', data: {
        'phone': phone,
        'name': name,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Vérifie l'OTP et stocke le JWT
  Future<void> verifyOtp(String phone, String otpCode) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'phone': phone,
        'otpCode': otpCode,
      });

      final token = response.data['token'];
      if (token != null) {
        await _storage.write(key: _tokenKey, value: token);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le token actuel
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Déconnecte l'utilisateur
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
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
