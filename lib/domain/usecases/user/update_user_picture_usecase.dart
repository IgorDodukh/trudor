import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/user/user.dart';
import '../../repositories/user_repository.dart';

class UpdateUserPictureUseCase implements UseCase<User, String> {
  final UserRepository repository;

  UpdateUserPictureUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(String pictureUrl) async {
    return await repository.updateUserPicture(pictureUrl);
  }
}
