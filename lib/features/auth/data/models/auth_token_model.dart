class AuthTokenModel {
  final String token;
  final String? refreshToken;
  final bool isNewUser;

  const AuthTokenModel({
    required this.token,
    this.refreshToken,
    required this.isNewUser,
  }) : assert(token != '', 'token must not be empty');
}
