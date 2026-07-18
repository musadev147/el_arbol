import 'package:dio/dio.dart';
import '../../featuers/auth/data/repositories/auth_repository_impl.dart';
import '../../featuers/auth/data/services/auth_service.dart';
import '../../featuers/auth/domain/repositories/auth_repository.dart';
import '../endpoints.dart';
import 'auth_interceptor.dart';
import 'log.dart';
import 'token_storage.dart';

/// Clean Client wrapper that initializes and sets up Dio with custom interceptors and headers.
class DioClient {
  late final Dio dio;
  final AuthRepository authRepository;

  DioClient({
    Dio? dio,
    AuthRepository? authRepository,
  }) : authRepository = authRepository ??
            AuthRepositoryImpl(
              authService: AuthService(),
              tokenStorage: TokenStorage(),
            ) {
    this.dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: url!,
            connectTimeout: const Duration(milliseconds: 100000),
            receiveTimeout: const Duration(milliseconds: 100000),
            headers: {
              NetworkConstants.ACCEPT: NetworkConstants.ACCEPT_TYPE,
              NetworkConstants.ACCEPT_LANGUAGE: NetworkConstants.ACCEPT_LANGUAGE_VALUE,
              NetworkConstants.APP_KEY: NetworkConstants.APP_KEY_VALUE,
            },
          ),
        );

    // Register our auth and logger interceptors
    this.dio.interceptors.addAll([
      AuthInterceptor(authRepository: this.authRepository),
      Logger(),
    ]);
  }
}
