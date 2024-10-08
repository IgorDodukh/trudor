import 'package:dartz/dartz.dart';
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/core/usecases/usecase.dart';
import 'package:spoto/domain/repositories/delivery_info_repository.dart';
import 'package:spoto/domain/usecases/delivery_info/get_remote_delivery_info_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/constant_objects.dart';

class MockFavoritesRepository extends Mock implements DeliveryInfoRepository {}

void main() {
  late GetRemoteDeliveryInfoUseCase usecase;
  late MockFavoritesRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockFavoritesRepository();
    usecase = GetRemoteDeliveryInfoUseCase(mockProductRepository);
  });

  test(
    'Should get delivery info from the repository when DeliveryInfo Repository add data successfully',
        () async {
      /// Arrange
      when(() => mockProductRepository.getRemoteDeliveryInfo())
          .thenAnswer((_) async => const Right(tDeliveryInfoModel));

      /// Act
      final result = await usecase(NoParams());

      /// Assert
      result.fold(
            (failure) => fail('Test Fail!'),
            (favorites) => expect(favorites, tDeliveryInfoModel),
      );
      verify(() => mockProductRepository.getRemoteDeliveryInfo());
      verifyNoMoreInteractions(mockProductRepository);
    },
  );

  test('should return a Failure from the repository', () async {
    /// Arrange
    final failure = NetworkFailure();
    when(() => mockProductRepository.getRemoteDeliveryInfo())
        .thenAnswer((_) async => Left(failure));

    /// Act
    final result = await usecase(NoParams());

    /// Assert
    expect(result, Left(failure));
    verify(() => mockProductRepository.getRemoteDeliveryInfo());
    verifyNoMoreInteractions(mockProductRepository);
  });
}
