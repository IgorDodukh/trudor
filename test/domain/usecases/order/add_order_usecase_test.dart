import 'package:dartz/dartz.dart';
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/domain/repositories/order_repository.dart';
import 'package:spoto/domain/usecases/order/add_order_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/constant_objects.dart';

class MockFavoritesRepository extends Mock implements OrderRepository {}

void main() {
  late AddOrderUseCase usecase;
  late MockFavoritesRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockFavoritesRepository();
    usecase = AddOrderUseCase(mockProductRepository);
  });

  test(
    'Should get order from the repository when Order Repository add data successfully',
        () async {
      /// Arrange
      when(() => mockProductRepository.addOrder(tOrderDetailsModel))
          .thenAnswer((_) async => Right(tOrderDetailsModel));

      /// Act
      final result = await usecase(tOrderDetailsModel);

      /// Assert
      result.fold(
            (failure) => fail('Test Fail!'),
            (favorites) => expect(favorites, tOrderDetailsModel),
      );
      verify(() => mockProductRepository.addOrder(tOrderDetailsModel));
      verifyNoMoreInteractions(mockProductRepository);
    },
  );

  test('should return a Failure from the repository', () async {
    /// Arrange
    final failure = NetworkFailure();
    when(() => mockProductRepository.addOrder(tOrderDetailsModel))
        .thenAnswer((_) async => Left(failure));

    /// Act
    final result = await usecase(tOrderDetailsModel);

    /// Assert
    expect(result, Left(failure));
    verify(() => mockProductRepository.addOrder(tOrderDetailsModel));
    verifyNoMoreInteractions(mockProductRepository);
  });
}
