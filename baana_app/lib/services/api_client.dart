import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';

class ApiClient {
  static const String _baseUrl = 'https://baana-app.onrender.com/api'; // Point vers le backend Render en production
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
        _storage = storage ?? const FlutterSecureStorage();

  Future<void> init() async {
    // path_provider (getTemporaryDirectory) ne fonctionne pas sur Web
    if (!kIsWeb) {
      final dir = await getTemporaryDirectory();
      final cacheOptions = CacheOptions(
        store: HiveCacheStore(dir.path),
        policy: CachePolicy.request,
        hitCacheOnErrorExcept: [401, 403],
        maxStale: const Duration(days: 7),
        priority: CachePriority.normal,
        cipher: null,
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        allowPostMethod: false,
      );
      _dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
    }
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
