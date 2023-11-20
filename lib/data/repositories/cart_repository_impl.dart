import 'package:dartz/dartz.dart';
import 'package:trudor/data/data_sources/remote/cart_firebase_data_source.dart';

import '../../../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/cart/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../data_sources/local/cart_local_data_source.dart';
import '../data_sources/local/user_local_data_source.dart';
import '../models/cart/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartFirebaseDataSource firebaseDataSource;
  final CartLocalDataSource localDataSource;
  final UserLocalDataSource userLocalDataSource;
  final NetworkInfo networkInfo;

  CartRepositoryImpl({
    required this.firebaseDataSource,
    required this.localDataSource,
    required this.userLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, CartItem>> addToCart(CartItem params) async {
    // TODO: Implement a method to add a product to the when user is logged in
    if (await userLocalDataSource.isTokenAvailable()) {
      await localDataSource.saveCartItem(CartItemModel.fromParent(params));
      final remoteProduct = await firebaseDataSource.addToFavorites(CartItemModel.fromParent(params));
      return Right(remoteProduct);
    } else {
      print("CartRepositoryImpl.addToCart.isTokenAvailable.else");
      await localDataSource.saveCartItem(CartItemModel.fromParent(params));
      return Right(params);
    }
  }

  @override
  Future<Either<Failure, bool>> deleteFormCart(CartItem params) async {
    try {
      bool result = await localDataSource.removeCartItem(CartItemModel.fromParent(params));
      await firebaseDataSource.removeFromFavorites(CartItemModel.fromParent(params));
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
  Future<Either<Failure, List<CartItem>>> getCachedCart() async {
    try {
      final localProducts = await localDataSource.getCart();
      return Right(localProducts);
    } on Failure catch (failure) {
      print("getCachedCart failure: $failure");
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> syncCart() async {
    if (await networkInfo.isConnected) {
      if (await userLocalDataSource.isTokenAvailable()) {
        List<CartItemModel> localCartItems = [];
        try {
          localCartItems = await localDataSource.getCart();
        } on Failure catch (_) {}
        try {
          final syncedResult = await firebaseDataSource.syncCart(
            localCartItems,
          );
          print("Saving cart items: $syncedResult");
          await localDataSource.saveCart(syncedResult);
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
  Future<Either<Failure, bool>> clearCart() async {
    bool result = await localDataSource.clearCart();
    if (result) {
      return Right(result);
    } else {
      return Left(CacheFailure());
    }
  }
}
