abstract class Failure {
  const Failure(this.message);
  final String message;
  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized']);
}
