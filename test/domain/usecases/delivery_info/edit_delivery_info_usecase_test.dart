import 'package:dartz/dartz.dart';
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/domain/repositories/delivery_info_repository.dart';
import 'package:spoto/domain/usecases/delivery_info/edit_delivery_info_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/constant_objects.dart';

class MockFavoritesRepository extends Mock implements DeliveryInfoRepository {}

void main() {
  late EditDeliveryInfoUseCase usecase;
  late MockFavoritesRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockFavoritesRepository();
    usecase = EditDeliveryInfoUseCase(mockProductRepository);
  });

  test(
    'Should get delivery info from the repository when DeliveryInfo Repository edit data successfully',
        () async {
      /// Arrange
      when(() => mockProductRepository.editDeliveryInfo(tDeliveryInfoModel))
          .thenAnswer((_) async => const Right(tDeliveryInfoModel));

      /// Act
      final result = await usecase(tDeliveryInfoModel);

      /// Assert
      result.fold(
            (failure) => fail('Test Fail!'),
            (favorites) => expect(favorites, tDeliveryInfoModel),
      );
      verify(() => mockProductRepository.editDeliveryInfo(tDeliveryInfoModel));
      verifyNoMoreInteractions(mockProductRepository);
    },
  );

  test('should return a Failure from the repository', () async {
    /// Arrange
    final failure = NetworkFailure();
    when(() => mockProductRepository.editDeliveryInfo(tDeliveryInfoModel))
        .thenAnswer((_) async => Left(failure));

    /// Act
    final result = await usecase(tDeliveryInfoModel);

    /// Assert
    expect(result, Left(failure));
    verify(() => mockProductRepository.editDeliveryInfo(tDeliveryInfoModel));
    verifyNoMoreInteractions(mockProductRepository);
  });
}
