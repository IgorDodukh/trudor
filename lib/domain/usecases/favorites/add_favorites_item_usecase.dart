import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/favorites/favorites_item.dart';
import '../../repositories/favorites_repository.dart';

class AddFavoritesUseCase implements UseCase<void, FavoritesItem> {
  final FavoritesRepository repository;
  AddFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(FavoritesItem params) async {
    return await repository.addToFavorites(params);
  }
}
