import 'package:dio/dio.dart';
import '../../../../networks/endpoints.dart';

/// Data source service to handle token refresh API calls.
class AuthService {
  final Dio _dio;

  AuthService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: url!));

  /// Requests a new JWT access/refresh token pair using the stored refresh token.
  Future<Map<String, dynamic>> refreshSession(String refreshToken) async {
    try {
      final response = await _dio.post(
        Endpoints.refreshToken(),
        data: {
          'refresh': refreshToken,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
      }
      
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    } catch (e) {
      rethrow;
    }
  }
}
