import 'package:dartz/dartz.dart';
import 'package:trudor/core/error/failures.dart';
import 'package:trudor/core/usecases/usecase.dart';
import 'package:trudor/domain/repositories/favorites_repository.dart';
import 'package:trudor/domain/usecases/favorites/clear_favorites_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late ClearFavoritesUseCase usecase;
  late MockFavoritesRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockFavoritesRepository();
    usecase = ClearFavoritesUseCase(mockProductRepository);
  });

  test(
    'Should get clea item from the repository when Favorites Repository clear data successfully',
    () async {
      /// Arrange
      when(() => mockProductRepository.clearFavorites())
          .thenAnswer((_) async => const Right(true));

      /// Act
      final result = await usecase(NoParams());

      /// Assert
      expect(result, const Right(true));
      verify(() => mockProductRepository.clearFavorites());
      verifyNoMoreInteractions(mockProductRepository);
    },
  );

  test('should return a Failure from the repository', () async {
    /// Arrange
    final failure = NetworkFailure();
    when(() => mockProductRepository.clearFavorites())
        .thenAnswer((_) async => Left(failure));

    /// Act
    final result = await usecase(NoParams());

    /// Assert
    expect(result, Left(failure));
    verify(() => mockProductRepository.clearFavorites());
    verifyNoMoreInteractions(mockProductRepository);
  });
}
