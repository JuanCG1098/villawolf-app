import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'providers.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({required this.status, this.user, this.error});

  final AuthStatus status;
  final AuthUser? user;
  final String? error;

  static const unknown = AuthState(status: AuthStatus.unknown);
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(AuthState.unknown) {
    _restore();
  }

  final Ref _ref;

  Future<void> _restore() async {
    final token = await _ref.read(tokenStorageProvider).read();
    if (token == null || token.isEmpty) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    _ref.read(authTokenProvider.notifier).state = token;
    try {
      final me = await _ref.read(apiProvider).me();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: AuthUser(
          userId: (me['userId'] ?? '') as String,
          displayName: (me['displayName'] ?? '') as String,
          email: (me['email'] ?? '') as String,
          role: (me['role'] ?? '') as String,
          accessToken: token,
          expiresAtUtc: DateTime.now().toUtc(),
        ),
      );
    } catch (_) {
      await logout();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final user = await _ref.read(apiProvider).login(email, password);
      _ref.read(authTokenProvider.notifier).state = user.accessToken;
      await _ref.read(tokenStorageProvider).save(user.accessToken);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } on DioException catch (e) {
      final message = e.response?.statusCode == 401
          ? 'Email o contraseña inválidos.'
          : 'No se pudo conectar con el servidor.';
      state = AuthState(status: AuthStatus.unauthenticated, error: message);
      return false;
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated, error: 'Error inesperado.');
      return false;
    }
  }

  Future<void> logout() async {
    await _ref.read(tokenStorageProvider).clear();
    _ref.read(authTokenProvider.notifier).state = null;
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) => AuthController(ref));
