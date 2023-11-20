import 'package:dartz/dartz.dart';
import 'package:trudor/core/error/failures.dart';
import 'package:trudor/core/usecases/usecase.dart';
import 'package:trudor/domain/entities/user/user.dart';
import 'package:trudor/domain/repositories/user_repository.dart';

class GoogleAuthUseCase implements UseCase<User, SignInGoogleParams> {

  final UserRepository repository;
  GoogleAuthUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInGoogleParams params) async {
    print("call in GoogleAuthUseCase");
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
