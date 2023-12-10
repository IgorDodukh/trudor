import 'package:dartz/dartz.dart';
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/domain/repositories/category_repository.dart';
import 'package:spoto/domain/usecases/category/filter_category_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/constant_objects.dart';

class MockFavoritesRepository extends Mock implements CategoryRepository {}

void main() {
  late FilterCategoryUseCase usecase;
  late MockFavoritesRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockFavoritesRepository();
    usecase = FilterCategoryUseCase(mockProductRepository);
  });

  test(
    'Should get category from the repository when Category Repository add data successfully',
        () async {
      /// Arrange
      when(() => mockProductRepository.filterCachedCategories('search-word'))
          .thenAnswer((_) async => const Right([tCategoryModel]));

      /// Act
      final result = await usecase('search-word');

      /// Assert
      result.fold(
            (failure) => fail('Test Fail!'),
            (favorites) => expect(favorites, [tCategoryModel]),
      );
      verify(() => mockProductRepository.filterCachedCategories('search-word'));
      verifyNoMoreInteractions(mockProductRepository);
    },
  );

  test('should return a Failure from the repository', () async {
    /// Arrange
    final failure = NetworkFailure();
    when(() => mockProductRepository.filterCachedCategories('search-word'))
        .thenAnswer((_) async => Left(failure));

    /// Act
    final result = await usecase('search-word');

    /// Assert
    expect(result, Left(failure));
    verify(() => mockProductRepository.filterCachedCategories('search-word'));
    verifyNoMoreInteractions(mockProductRepository);
  });
}
