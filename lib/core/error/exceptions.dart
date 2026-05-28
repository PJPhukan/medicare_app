class ServerException implements Exception {
  const ServerException([this.message = 'Server error']);
  final String message;
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection']);
  final String message;
  @override
  String toString() => message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Cache error']);
  final String message;
  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = 'Unauthorized']);
  final String message;
  @override
  String toString() => message;
}
