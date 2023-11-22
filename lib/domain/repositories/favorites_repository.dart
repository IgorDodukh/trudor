import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/favorites/favorites_item.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<FavoritesItem>>> getCachedFavorites();
  Future<Either<Failure, List<FavoritesItem>>> syncFavorites();
  Future<Either<Failure, FavoritesItem>> addToFavorites(FavoritesItem params);
  Future<Either<Failure, bool>> deleteFormFavorites(FavoritesItem params);
  Future<Either<Failure, bool>> clearFavorites();
}