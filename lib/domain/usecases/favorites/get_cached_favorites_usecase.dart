import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/favorites/favorites_item.dart';
import '../../repositories/favorites_repository.dart';

class GetCachedFavoritesUseCase implements UseCase<List<ListViewItem>, NoParams> {
  final FavoritesRepository repository;
  GetCachedFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ListViewItem>>> call(NoParams params) async {
    return await repository.getCachedFavorites();
  }
}
