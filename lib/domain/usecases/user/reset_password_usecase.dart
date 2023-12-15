import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../repositories/user_repository.dart';

class ResetPasswordUseCase implements UseCase<NoParams, ResetPasswordParams> {
  final UserRepository repository;
  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, NoParams>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(params);
  }
}

class ResetPasswordParams {
  final String resetCode;
  final String newPassword;
  const ResetPasswordParams({
    required this.resetCode,
    required this.newPassword,
  });
}