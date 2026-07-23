import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as get_route;
import '../../featuers/auth/domain/repositories/auth_repository.dart';
import '../../route/app_pages.dart';

/// Interceptor that handles JWT authorization headers and handles token refreshing automatically.
class AuthInterceptor extends Interceptor {
  final AuthRepository authRepository;
  
  bool _isRefreshing = false;
  Completer<String?>? _refreshTokenCompleter;

  AuthInterceptor({required this.authRepository});

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await authRepository.getAccessToken();
    if (token != null && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    // Check if error is due to HTTP 401 Unauthorized
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;
      
      final refreshToken = await authRepository.getRefreshToken();
      if (refreshToken == null) {
        await _handleLogout();
        handler.reject(err);
        return;
      }

      String? newAccessToken;

      try {
        if (_isRefreshing) {
          // If a refresh is already in progress, wait for its result.
          newAccessToken = await _refreshTokenCompleter?.future;
        } else {
          _isRefreshing = true;
          _refreshTokenCompleter = Completer<String?>();

          // Perform token refresh API call via Repository
          final tokenPair = await authRepository.refreshAccessToken(refreshToken);
          await authRepository.saveTokens(tokenPair);

          newAccessToken = tokenPair.accessToken;
          _refreshTokenCompleter?.complete(newAccessToken);
          _isRefreshing = false;
        }
      } catch (refreshErr) {
        _refreshTokenCompleter?.completeError(refreshErr);
        _isRefreshing = false;
        await _handleLogout();
        handler.reject(err);
        return;
      }

      if (newAccessToken != null) {
        try {
          // Update request header with the fresh token
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          // Retry request with the updated headers using a fresh Dio client
          final response = await _retryRequest(requestOptions);
          handler.resolve(response);
          return;
        } catch (retryErr) {
          handler.reject(DioException(
            requestOptions: requestOptions,
            error: retryErr,
          ));
          return;
        }
      }
    }

    super.onError(err, handler);
  }

  /// Clears stored JWT credentials and navigates the user back to the Login screen.
  Future<void> _handleLogout() async {
    await authRepository.clearSession();
    // Redirect to role selection using GetX Route management
    get_route.Get.offAllNamed(Routes.ROLE_SELECTION);
  }

  /// Retries a request using a fresh Dio instance to prevent infinite loops.
  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) {
    final dio = Dio(BaseOptions(baseUrl: requestOptions.baseUrl));
    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        contentType: requestOptions.contentType,
        responseType: requestOptions.responseType,
        extra: requestOptions.extra,
      ),
    );
  }
}
