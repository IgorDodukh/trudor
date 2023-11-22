import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../repositories/favorites_repository.dart';

class ClearFavoritesUseCase implements UseCase<bool, NoParams> {
  final FavoritesRepository repository;
  ClearFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.clearFavorites();
  }
}
