import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/favorites/favorites_item.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<ListViewItem>>> getCachedFavorites();
  Future<Either<Failure, List<ListViewItem>>> syncFavorites();
  Future<Either<Failure, ListViewItem>> addToFavorites(ListViewItem params);
  Future<Either<Failure, bool>> deleteFormFavorites(ListViewItem params);
  Future<Either<Failure, bool>> clearFavorites();
}