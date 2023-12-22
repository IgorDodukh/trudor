import 'package:dartz/dartz.dart';
import 'package:spoto/domain/entities/product/product.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/product/product_response.dart';
import '../../repositories/product_repository.dart';

class UpdateProductUseCase
    implements UseCase<ProductResponse, UpdateProductParams> {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  @override
  Future<Either<Failure, ProductResponse>> call(
      UpdateProductParams params) async {
    return await repository.updateProduct(params);
  }
}

class UpdateProductParams {
  final Product product;
  final bool isPublicationsAction;

  const UpdateProductParams({
    required this.product,
    required this.isPublicationsAction,
  });

  UpdateProductParams copyWith({
    required Product product,
    bool? isPublicationsAction,
  }) =>
      UpdateProductParams(
        product: this.product,
        isPublicationsAction: isPublicationsAction ?? this.isPublicationsAction,
      );
}
