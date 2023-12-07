import 'package:dartz/dartz.dart';
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/core/usecases/usecase.dart';
import 'package:spoto/domain/repositories/category_repository.dart';
import 'package:spoto/domain/usecases/category/get_remote_category_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/constant_objects.dart';

class MockFavoritesRepository extends Mock implements CategoryRepository {}

void main() {
  late GetRemoteCategoryUseCase usecase;
  late MockFavoritesRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockFavoritesRepository();
    usecase = GetRemoteCategoryUseCase(mockProductRepository);
  });

  test(
    'Should get category from the repository when Category Repository add data successfully',
        () async {
      /// Arrange
      when(() => mockProductRepository.getRemoteCategories())
          .thenAnswer((_) async => const Right([tCategoryModel]));

      /// Act
      final result = await usecase(NoParams());

      /// Assert
      result.fold(
            (failure) => fail('Test Fail!'),
            (favorites) => expect(favorites, [tCategoryModel]),
      );
      verify(() => mockProductRepository.getRemoteCategories());
      verifyNoMoreInteractions(mockProductRepository);
    },
  );

  test('should return a Failure from the repository', () async {
    /// Arrange
    final failure = NetworkFailure();
    when(() => mockProductRepository.getRemoteCategories())
        .thenAnswer((_) async => Left(failure));

    /// Act
    final result = await usecase(NoParams());

    /// Assert
    expect(result, Left(failure));
    verify(() => mockProductRepository.getRemoteCategories());
    verifyNoMoreInteractions(mockProductRepository);
  });
}
