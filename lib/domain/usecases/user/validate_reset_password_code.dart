import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../repositories/user_repository.dart';

class ValidateResetPasswordUseCase implements UseCase<NoParams, String> {
  final UserRepository repository;
  ValidateResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, NoParams>> call(String code) async {
    return await repository.validateResetPasswordCode(code);
  }
}
