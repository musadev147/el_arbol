class TokenPair {
  final String accessToken;
  final String? refreshToken;

  TokenPair({required this.accessToken, this.refreshToken});
}

/// Abstract contract for authentication repository.
abstract class AuthRepository {
  /// Calls backend refresh token endpoint and returns new TokenPair.
  Future<TokenPair> refreshAccessToken(String refreshToken);

  /// Stores token pair in secure storage.
  Future<void> saveTokens(TokenPair tokenPair);

  /// Retrieves cached access token.
  Future<String?> getAccessToken();

  /// Retrieves cached refresh token.
  Future<String?> getRefreshToken();

  /// Clears stored tokens on logout or session expiration.
  Future<void> clearSession();
}
