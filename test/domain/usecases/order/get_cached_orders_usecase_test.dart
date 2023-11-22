import 'package:dartz/dartz.dart';
import 'package:trudor/core/error/failures.dart';
import 'package:trudor/core/usecases/usecase.dart';
import 'package:trudor/domain/repositories/order_repository.dart';
import 'package:trudor/domain/usecases/order/get_cached_orders_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/constant_objects.dart';

class MockFavoritesRepository extends Mock implements OrderRepository {}

void main() {
  late GetCachedOrdersUseCase usecase;
  late MockFavoritesRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockFavoritesRepository();
    usecase = GetCachedOrdersUseCase(mockProductRepository);
  });

  test(
    'Should get order from the repository when Order Repository add data successfully',
        () async {
      /// Arrange
      when(() => mockProductRepository.getCachedOrders())
          .thenAnswer((_) async => Right([tOrderDetailsModel]));

      /// Act
      final result = await usecase(NoParams());

      /// Assert
      result.fold(
            (failure) => fail('Test Fail!'),
            (favorites) => expect(favorites, [tOrderDetailsModel]),
      );
      verify(() => mockProductRepository.getCachedOrders());
      verifyNoMoreInteractions(mockProductRepository);
    },
  );

  test('should return a Failure from the repository', () async {
    /// Arrange
    final failure = NetworkFailure();
    when(() => mockProductRepository.getCachedOrders())
        .thenAnswer((_) async => Left(failure));

    /// Act
    final result = await usecase(NoParams());

    /// Assert
    expect(result, Left(failure));
    verify(() => mockProductRepository.getCachedOrders());
    verifyNoMoreInteractions(mockProductRepository);
  });
}
