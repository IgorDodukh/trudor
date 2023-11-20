import 'package:dartz/dartz.dart';
import 'package:eshop/domain/entities/cart/cart_item.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../repositories/cart_repository.dart';

class RemoveCartItemUseCase implements UseCase<void, CartItem> {
  final CartRepository repository;
  RemoveCartItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CartItem params) async {
    return await repository.deleteFormCart(params);
  }
}
