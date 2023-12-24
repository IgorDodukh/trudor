import 'package:dartz/dartz.dart';
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/core/usecases/usecase.dart';
import 'package:spoto/domain/entities/user/user.dart';
import 'package:spoto/domain/repositories/user_repository.dart';

class GoogleAuthUseCase implements UseCase<User, NoParams> {
  final UserRepository repository;

  GoogleAuthUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.googleSignIn(params);
  }
}

class SignInGoogleParams {
  final String id;
  final String displayName;
  final String email;
  final String photoUrl;

  const SignInGoogleParams({
    required this.id,
    required this.displayName,
    required this.email,
    required this.photoUrl,
  });
}
