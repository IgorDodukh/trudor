import 'package:dartz/dartz.dart';
import 'package:trudor/data/data_sources/remote/product_firebase_data_source.dart';
import 'package:trudor/domain/entities/product/product.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/product/product_response.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/product/get_product_usecase.dart';
import '../data_sources/local/product_local_data_source.dart';
import '../data_sources/remote/product_remote_data_source.dart';
import '../models/product/product_response_model.dart';

typedef _ConcreteOrProductChooser = Future<ProductResponse> Function();

class ProductRepositoryImpl implements ProductRepository {
  final ProductFirebaseDataSource firebaseDataSource;
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.firebaseDataSource,
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  // TODO: https://medium.com/@ravipatel84184/flutter-auto-complete-search-list-step-by-step-implementation-guide-472a80d98e22
  // TODO: https://medium.com/codechai/implementing-search-in-flutter-17dc5aa72018

  @override
  Future<Either<Failure, ProductResponse>> getProducts(FilterProductParams params) async {
    return await _getProduct(() {
      return firebaseDataSource.getProducts(params);
    });
  }

  @override
  Future<Either<Failure, ProductResponse>> addProduct(Product params) async {
    return await _addProduct(() {
      return remoteDataSource.addProduct(params);
    });
  }

  Future<Either<Failure, ProductResponse>> _getProduct(
    _ConcreteOrProductChooser getConcreteOrProducts,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await getConcreteOrProducts();
        localDataSource.saveProducts(remoteProducts as ProductResponseModel);
        return Right(remoteProducts);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localProducts = await localDataSource.getLastProducts();
        return Right(localProducts);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  Future<Either<Failure, ProductResponse>> _addProduct(
    _ConcreteOrProductChooser getConcreteOrProducts,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await getConcreteOrProducts();
        localDataSource.saveProducts(remoteProducts as ProductResponseModel);
        return Right(remoteProducts);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localProducts = await localDataSource.getLastProducts();
        return Right(localProducts);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

}
