import 'package:dartz/dartz.dart';
import 'package:trudor/data/data_sources/remote/favorites_firebase_data_source.dart';

import '../../../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/favorites/favorites_item.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../data_sources/local/favorites_local_data_source.dart';
import '../data_sources/local/user_local_data_source.dart';
import '../models/favorites/favorites_item_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesFirebaseDataSource firebaseDataSource;
  final FavoritesLocalDataSource localDataSource;
  final UserLocalDataSource userLocalDataSource;
  final NetworkInfo networkInfo;

  FavoritesRepositoryImpl({
    required this.firebaseDataSource,
    required this.localDataSource,
    required this.userLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, FavoritesItem>> addToFavorites(FavoritesItem params) async {
    // TODO: Implement a method to add a product to the when user is logged in
    if (await userLocalDataSource.isTokenAvailable()) {
      await localDataSource.saveFavoritesItem(FavoritesItemModel.fromParent(params));
      final remoteProduct = await firebaseDataSource.addToFavorites(FavoritesItemModel.fromParent(params));
      return Right(remoteProduct);
    } else {
      await localDataSource.saveFavoritesItem(FavoritesItemModel.fromParent(params));
      return Right(params);
    }
  }

  @override
  Future<Either<Failure, bool>> deleteFormFavorites(FavoritesItem params) async {
    try {
      bool result = await localDataSource.removeFavoritesItem(FavoritesItemModel.fromParent(params));
      await firebaseDataSource.removeFromFavorites(FavoritesItemModel.fromParent(params));
      if (result) {
        return Right(result);
      } else {
        return Left(CacheFailure());
      }
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<FavoritesItem>>> getCachedFavorites() async {
    try {
      final localProducts = await localDataSource.getFavorites();
      return Right(localProducts);
    } on Failure catch (failure) {
      print("getCachedFavorites failure: $failure");
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<FavoritesItem>>> syncFavorites() async {
    if (await networkInfo.isConnected) {
      if (await userLocalDataSource.isTokenAvailable()) {
        List<FavoritesItemModel> localFavoritesItems = [];
        try {
          localFavoritesItems = await localDataSource.getFavorites();
        } on Failure catch (_) {}
        try {
          final syncedResult = await firebaseDataSource.syncFavorites(
            localFavoritesItems,
          );
          await localDataSource.saveFavorites(syncedResult);
          return Right(syncedResult);
        } on Failure catch (failure) {
          return Left(failure);
        }
      } else {
        return Left(NetworkFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> clearFavorites() async {
    bool result = await localDataSource.clearFavorites();
    if (result) {
      return Right(result);
    } else {
      return Left(CacheFailure());
    }
  }
}
