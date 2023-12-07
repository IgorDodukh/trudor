import 'package:dartz/dartz.dart';
import 'package:spoto/domain/entities/product/product.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/product/product_response.dart';
import '../../repositories/product_repository.dart';

class UpdateProductUseCase implements UseCase<ProductResponse, Product> {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  @override
  Future<Either<Failure, ProductResponse>> call(Product params) async {
    return await repository.updateProduct(params);
  }
}
