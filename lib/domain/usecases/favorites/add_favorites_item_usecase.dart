import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/favorites/favorites_item.dart';
import '../../repositories/favorites_repository.dart';

class AddFavoritesUseCase implements UseCase<void, ListViewItem> {
  final FavoritesRepository repository;
  AddFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ListViewItem params) async {
    return await repository.addToFavorites(params);
  }
}
