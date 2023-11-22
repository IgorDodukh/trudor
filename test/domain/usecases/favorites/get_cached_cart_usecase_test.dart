import 'package:dartz/dartz.dart';
import 'package:trudor/core/error/failures.dart';
import 'package:trudor/core/usecases/usecase.dart';
import 'package:trudor/domain/repositories/favorites_repository.dart';
import 'package:trudor/domain/usecases/favorites/get_cached_favorites_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/constant_objects.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late GetCachedFavoritesUseCase usecase;
  late MockFavoritesRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockFavoritesRepository();
    usecase = GetCachedFavoritesUseCase(mockProductRepository);
  });

  test(
    'Should get favorites item from the repository when Favorites Repository add data successfully',
    () async {
      /// Arrange
      when(() => mockProductRepository.getCachedFavorites())
          .thenAnswer((_) async => Right([tFavoritesItemModel]));

      /// Act
      final result = await usecase(NoParams());

      /// Assert
      result.fold(
        (failure) => fail('Test Fail!'),
        (favorites) => expect(favorites, [tFavoritesItemModel]),
      );
      verify(() => mockProductRepository.getCachedFavorites());
      verifyNoMoreInteractions(mockProductRepository);
    },
  );

  test('should return a Failure from the repository', () async {
    /// Arrange
    final failure = NetworkFailure();
    when(() => mockProductRepository.getCachedFavorites())
        .thenAnswer((_) async => Left(failure));

    /// Act
    final result = await usecase(NoParams());

    /// Assert
    expect(result, Left(failure));
    verify(() => mockProductRepository.getCachedFavorites());
    verifyNoMoreInteractions(mockProductRepository);
  });
}
