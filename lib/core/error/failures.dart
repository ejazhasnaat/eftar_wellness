sealed class Failure {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  const Failure(this.message, {this.cause, this.stackTrace});
  @override
  String toString() => '$runtimeType: $message';
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, {super.cause, super.stackTrace}) : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, {super.cause, super.stackTrace}) : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(String message, {super.cause, super.stackTrace}) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message, {super.cause, super.stackTrace}) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message, {super.cause, super.stackTrace}) : super(message);
}
