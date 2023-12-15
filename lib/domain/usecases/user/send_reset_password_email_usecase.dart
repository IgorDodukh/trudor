import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../repositories/user_repository.dart';

class SendResetPasswordEmailUseCase implements UseCase<NoParams, String> {
  final UserRepository repository;
  SendResetPasswordEmailUseCase(this.repository);

  @override
  Future<Either<Failure, NoParams>> call(String email) async {
    return await repository.sendPasswordResetEmail(email);
  }
}
