import '../../domain/repositories/auth_repository.dart';
import '../../../../networks/dio/token_storage.dart';
import '../services/auth_service.dart';

/// Implementation of the AuthRepository.
class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.authService,
    required this.tokenStorage,
  });

  @override
  Future<TokenPair> refreshAccessToken(String refreshToken) async {
    final response = await authService.refreshSession(refreshToken);
    final String access = response['access'] as String;
    final String? refresh = response['refresh'] as String?;

    return TokenPair(accessToken: access, refreshToken: refresh);
  }

  @override
  Future<void> saveTokens(TokenPair tokenPair) async {
    await tokenStorage.saveAccessToken(tokenPair.accessToken);
    if (tokenPair.refreshToken != null) {
      await tokenStorage.saveRefreshToken(tokenPair.refreshToken!);
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return await tokenStorage.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() async {
    return await tokenStorage.getRefreshToken();
  }

  @override
  Future<void> clearSession() async {
    await tokenStorage.clearTokens();
  }
}
