import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_config.dart';
import '../core/token_storage.dart';
import '../services/api_service.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

/// Current JWT in memory. The Dio interceptor reads it per request; the auth controller keeps it
/// in sync. Kept separate from the auth controller to avoid a provider dependency cycle.
final authTokenProvider = StateProvider<String?>((ref) => null);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = ref.read(authTokenProvider);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  ));

  return dio;
});

final apiProvider = Provider<ApiService>((ref) => ApiService(ref.read(dioProvider)));
