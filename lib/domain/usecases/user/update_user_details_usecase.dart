import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/user/user.dart';
import '../../repositories/user_repository.dart';

class UpdateUserDetailsUseCase implements UseCase<User, UserDetailsParams> {
  final UserRepository repository;

  UpdateUserDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UserDetailsParams params) async {
    return await repository.updateUserDetails(params);
  }
}

class UserDetailsParams {
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;

  const UserDetailsParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
  });
}
