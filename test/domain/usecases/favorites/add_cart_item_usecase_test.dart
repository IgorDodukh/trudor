import 'package:dartz/dartz.dart';
import 'package:trudor/core/error/failures.dart';
import 'package:trudor/domain/repositories/favorites_repository.dart';
import 'package:trudor/domain/usecases/favorites/add_favorites_item_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/constant_objects.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late AddFavoritesUseCase usecase;
  late MockFavoritesRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockFavoritesRepository();
    usecase = AddFavoritesUseCase(mockProductRepository);
  });

  test(
    'Should get Favorites item from the repository when Favorites Repository add data successfully',
    () async {
      /// Arrange
      when(() => mockProductRepository.addToFavorites(tFavoritesItemModel))
          .thenAnswer((_) async => Right(tFavoritesItemModel));

      /// Act
      final result = await usecase(tFavoritesItemModel);

      /// Assert
      expect(result, Right(tFavoritesItemModel));
      verify(() => mockProductRepository.addToFavorites(tFavoritesItemModel));
      verifyNoMoreInteractions(mockProductRepository);
    },
  );

  test('should return a Failure from the repository', () async {
    /// Arrange
    final failure = NetworkFailure();
    when(() => mockProductRepository.addToFavorites(tFavoritesItemModel))
        .thenAnswer((_) async => Left(failure));

    /// Act
    final result = await usecase(tFavoritesItemModel);

    /// Assert
    expect(result, Left(failure));
    verify(
        () => mockProductRepository.addToFavorites(tFavoritesItemModel));
    verifyNoMoreInteractions(mockProductRepository);
  });
}
