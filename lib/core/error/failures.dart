import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

// General failures
class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class NetworkFailure extends Failure {}

class ExceptionFailure extends Failure {}

class CredentialFailure extends Failure {}

class AuthenticationFailure extends Failure {}

class InvalidEmailFailure extends Failure {}

class ExistingEmailFailure extends Failure {}

class WeakPasswordFailure extends Failure {}

class UserNotFoundFailure extends Failure {}