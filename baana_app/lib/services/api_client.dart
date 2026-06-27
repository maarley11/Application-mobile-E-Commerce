import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static const String _baseUrl = 'http://localhost:3000/api'; // Changé pour localhost car on est sur Web
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )),
        _storage = storage ?? const FlutterSecureStorage() {
    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Injection automatique du token JWT s'il existe
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            print('🌐 [API Request] ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ [API Response] ${response.statusCode} ${response.requestOptions.uri}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (kDebugMode) {
            print('❌ [API Error] ${e.response?.statusCode} ${e.requestOptions.uri}');
            print('❌ [API Error Message] ${e.message}');
            print('❌ [API Error Data] ${e.response?.data}');
          }

          // Gestion des erreurs globales (ex: Token expiré)
          if (e.response?.statusCode == 401) {
            // Optionnel: implémenter un refresh token ou forcer la déconnexion
            await _storage.delete(key: 'jwt_token');
          }

          return handler.next(e);
        },
      ),
    );
  }

  // Getter pour accéder facilement à l'instance Dio configurée
  Dio get client => _dio;

  // Helpers pour le stockage du token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
}

// Instance globale (Singleton) pour une utilisation facile
final apiClient = ApiClient();
