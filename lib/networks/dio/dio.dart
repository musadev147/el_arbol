import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../featuers/auth/data/repositories/auth_repository_impl.dart';
import '../../featuers/auth/data/services/auth_service.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';
import '/helpers/di.dart';
import '../../constants/app_constants.dart';
import '../endpoints.dart';
import 'log.dart';

final class DioSingleton {
  static final DioSingleton _singleton = DioSingleton._internal();
  static CancelToken cancelToken = CancelToken();
  DioSingleton._internal();

  static DioSingleton get instance => _singleton;

  late Dio dio;

  late final AuthInterceptor _authInterceptor = AuthInterceptor(
    authRepository: AuthRepositoryImpl(
      authService: AuthService(),
      tokenStorage: TokenStorage(),
    ),
  );

  void create() {
    BaseOptions options = BaseOptions(
        baseUrl: url!,
        connectTimeout: const Duration(milliseconds: 100000),
        receiveTimeout: const Duration(milliseconds: 100000),
        headers: {
          NetworkConstants.ACCEPT: NetworkConstants.ACCEPT_TYPE,
          NetworkConstants.ACCEPT_LANGUAGE: appData.read(kKeyCountryCode) ?? "pt",
          NetworkConstants.APP_KEY: NetworkConstants.APP_KEY_VALUE,
        });
        
    final token = appData.read(kKeyAccessToken);
    if (token != null && token.toString().trim().isNotEmpty) {
      options.headers[NetworkConstants.AUTHORIZATION] = "Bearer $token";
    }
    
    dio = Dio(options)..interceptors.addAll([_authInterceptor, Logger()]);
  }

  void update(String auth) {
    if (kDebugMode) {
      print("Dio update");
    }
    BaseOptions options = BaseOptions(
      baseUrl: url!,
      responseType: ResponseType.json,
      headers: {
        NetworkConstants.ACCEPT: NetworkConstants.ACCEPT_TYPE,
        NetworkConstants.ACCEPT_LANGUAGE: appData.read(kKeyLanguage) ?? "pt",
        NetworkConstants.APP_KEY: NetworkConstants.APP_KEY_VALUE,
      },
      connectTimeout: const Duration(milliseconds: 100000),
      receiveTimeout: const Duration(milliseconds: 100000),
    );
    
    if (auth.trim().isNotEmpty) {
      options.headers[NetworkConstants.AUTHORIZATION] = "Bearer $auth";
    }
    
    dio = Dio(options)..interceptors.addAll([_authInterceptor, Logger()]);
  }

  void updateLanguage(String countryCode) {
    if (kDebugMode) {
      print("Dio update $countryCode");
    }
    BaseOptions options = BaseOptions(
      baseUrl: url!,
      responseType: ResponseType.json,
      headers: {
        NetworkConstants.ACCEPT: NetworkConstants.ACCEPT_TYPE,
        NetworkConstants.ACCEPT_LANGUAGE: countryCode,
        NetworkConstants.APP_KEY: NetworkConstants.APP_KEY_VALUE,
      },
      connectTimeout: const Duration(milliseconds: 100000),
      receiveTimeout: const Duration(milliseconds: 100000),
    );
    
    final token = appData.read(kKeyAccessToken);
    if (token != null && token.toString().trim().isNotEmpty) {
      options.headers[NetworkConstants.AUTHORIZATION] = "Bearer $token";
    }
    
    dio = Dio(options)..interceptors.addAll([_authInterceptor, Logger()]);
  }
}

Future<Response> postHttp(String path, [dynamic data]) =>
    DioSingleton.instance.dio.post(path, data: data, cancelToken: DioSingleton.cancelToken);

Future<Response> putHttp(String path, [dynamic data]) =>
    DioSingleton.instance.dio.put(path, data: data, cancelToken: DioSingleton.cancelToken);

Future<Response> getHttp(String path, [dynamic data]) =>
    DioSingleton.instance.dio.get(path, cancelToken: DioSingleton.cancelToken);

Future<Response> deleteHttp(String path, [dynamic data]) =>
    DioSingleton.instance.dio.delete(path, data: data, cancelToken: DioSingleton.cancelToken);

Future<Response> patchHttp(String path, [dynamic data]) =>
    DioSingleton.instance.dio.patch(path, data: data, cancelToken: DioSingleton.cancelToken);
