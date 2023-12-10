import 'package:dartz/dartz.dart';
import 'package:spoto/domain/entities/product/product.dart';

import '../../../../core/error/failures.dart';
import '../entities/product/product_response.dart';
import '../usecases/product/get_product_usecase.dart';

abstract class ProductRepository {
  Future<Either<Failure, ProductResponse>> getProducts(FilterProductParams params);
  Future<Either<Failure, ProductResponse>> updateProduct(Product params);
  Future<Either<Failure, ProductResponse>> addProduct(Product params);
}