import 'package:dartz/dartz.dart';
import 'package:trudor/domain/entities/favorites/favorites_item.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../repositories/favorites_repository.dart';

class RemoveFavoritesItemUseCase implements UseCase<void, ListViewItem> {
  final FavoritesRepository repository;
  RemoveFavoritesItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ListViewItem params) async {
    return await repository.deleteFormFavorites(params);
  }
}
