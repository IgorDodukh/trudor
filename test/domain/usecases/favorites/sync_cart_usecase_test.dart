import 'package:dartz/dartz.dart';
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/core/usecases/usecase.dart';
import 'package:spoto/domain/repositories/favorites_repository.dart';
import 'package:spoto/domain/usecases/favorites/sync_favorites_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/constant_objects.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late SyncFavoritesUseCase usecase;
  late MockFavoritesRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockFavoritesRepository();
    usecase = SyncFavoritesUseCase(mockProductRepository);
  });

  test(
    'Should get favorites item from the repository when Favorites Repository add data successfully',
        () async {
      /// Arrange
      when(() => mockProductRepository.syncFavorites())
          .thenAnswer((_) async => Right([tFavoritesItemModel]));

      /// Act
      final result = await usecase(NoParams());

      /// Assert
      result.fold(
            (failure) => fail('Test Fail!'),
            (favorites) => expect(favorites, [tFavoritesItemModel]),
      );
      verify(() => mockProductRepository.syncFavorites());
      verifyNoMoreInteractions(mockProductRepository);
    },
  );

  test('should return a Failure from the repository', () async {
    /// Arrange
    final failure = NetworkFailure();
    when(() => mockProductRepository.syncFavorites())
        .thenAnswer((_) async => Left(failure));

    /// Act
    final result = await usecase(NoParams());

    /// Assert
    expect(result, Left(failure));
    verify(() => mockProductRepository.syncFavorites());
    verifyNoMoreInteractions(mockProductRepository);
  });
}
