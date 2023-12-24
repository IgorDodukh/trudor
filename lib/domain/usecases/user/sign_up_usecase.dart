import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/user/user.dart';
import '../../repositories/user_repository.dart';

class SignUpUseCase implements UseCase<User, SignUpParams> {
  final UserRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    return await repository.signUp(params);
  }
}

class SignUpParams {
  final String name;
  final String email;
  final String? password;
  final String? phoneNumber;

  const SignUpParams({
    required this.name,
    required this.email,
    this.password,
    this.phoneNumber,
  });
}
