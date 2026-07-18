import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage helper class for managing JWT tokens.
class TokenStorage {
  final FlutterSecureStorage _secureStorage;

  TokenStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';

  /// Saves the access token in secure storage.
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _keyAccessToken, value: token);
  }

  /// Retrieves the access token from secure storage.
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _keyAccessToken);
  }

  /// Saves the refresh token in secure storage.
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _keyRefreshToken, value: token);
  }

  /// Retrieves the refresh token from secure storage.
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  /// Deletes both access and refresh tokens from secure storage.
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _keyAccessToken);
    await _secureStorage.delete(key: _keyRefreshToken);
  }
}
