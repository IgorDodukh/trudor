import 'package:dartz/dartz.dart';
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/core/usecases/usecase.dart';
import 'package:spoto/domain/entities/user/user.dart';
import 'package:spoto/domain/repositories/user_repository.dart';

class GoogleAuthUseCase implements UseCase<User, SignInGoogleParams> {

  final UserRepository repository;
  GoogleAuthUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInGoogleParams params) async {
    return await repository.googleSignIn(params);
  }
}

class SignInGoogleParams {
  final String id;
  final String displayName;
  final String email;
  const SignInGoogleParams({
    required this.id,
    required this.displayName,
    required this.email,
  });
}
