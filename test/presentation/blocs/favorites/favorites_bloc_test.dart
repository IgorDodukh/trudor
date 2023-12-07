import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/core/usecases/usecase.dart';
import 'package:spoto/domain/usecases/favorites/add_favorites_item_usecase.dart';
import 'package:spoto/domain/usecases/favorites/clear_favorites_usecase.dart';
import 'package:spoto/domain/usecases/favorites/get_cached_favorites_usecase.dart';
import 'package:spoto/domain/usecases/favorites/remove_favorites_item_usecase.dart';
import 'package:spoto/domain/usecases/favorites/sync_favorites_usecase.dart';
import 'package:spoto/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/constant_objects.dart';

class MockGetCachedFavoritesUseCase extends Mock implements GetCachedFavoritesUseCase {}

class MockAddFavoritesUseCase extends Mock implements AddFavoritesUseCase {}

class MockSyncFavoritesUseCase extends Mock implements SyncFavoritesUseCase {}

class MockClearFavoritesUseCase extends Mock implements ClearFavoritesUseCase {}

class MockRemoveFavoritesItemUseCase extends Mock implements RemoveFavoritesItemUseCase {}

void main() {
  group('FavoritesBloc', () {
    late FavoritesBloc favoritesBloc;
    late MockGetCachedFavoritesUseCase mockGetCachedFavoritesUseCase;
    late MockAddFavoritesUseCase mockAddFavoritesUseCase;
    late MockSyncFavoritesUseCase mockSyncFavoritesUseCase;
    late MockClearFavoritesUseCase mockClearFavoritesUseCase;
    late MockRemoveFavoritesItemUseCase mockRemoveFavoritesItemUseCase;

    setUp(() {
      mockGetCachedFavoritesUseCase = MockGetCachedFavoritesUseCase();
      mockAddFavoritesUseCase = MockAddFavoritesUseCase();
      mockSyncFavoritesUseCase = MockSyncFavoritesUseCase();
      mockClearFavoritesUseCase = MockClearFavoritesUseCase();
      mockRemoveFavoritesItemUseCase = MockRemoveFavoritesItemUseCase();

      favoritesBloc = FavoritesBloc(
        mockGetCachedFavoritesUseCase,
        mockAddFavoritesUseCase,
        mockSyncFavoritesUseCase,
        mockClearFavoritesUseCase,
        mockRemoveFavoritesItemUseCase,
      );
    });

    test('initial state should be FavoritesInitial', () {
      expect(favoritesBloc.state, const FavoritesInitial(favorites: []));
    });

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesLoading, FavoritesLoaded, FavoritesLoading, FavoritesLoaded] when GetFavorites is added',
      build: () {
        when(() => mockGetCachedFavoritesUseCase(NoParams()))
            .thenAnswer((_) async => const Right([]));
        when(() => mockSyncFavoritesUseCase(NoParams()))
            .thenAnswer((_) async => const Right([]));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(const GetFavorites()),
      expect: () => [
        const FavoritesLoading(favorites: []),
        const FavoritesLoaded(favorites: []),
        const FavoritesLoading(favorites: []),
        const FavoritesLoaded(favorites: []),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesLoading, FavoritesLoaded] when AddProduct is added',
      build: () {
        when(() => mockAddFavoritesUseCase(tFavoritesItemModel))
            .thenAnswer((_) async => const Right(''));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(AddProduct(favoritesItem: tFavoritesItemModel)),
      expect: () => [
        const FavoritesLoading(favorites: []),
        const FavoritesLoaded(favorites: []),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesLoading, FavoritesLoaded] when ClearFavorites is added',
      build: () {
        when(() => mockClearFavoritesUseCase(NoParams()))
            .thenAnswer((_) async => const Right(true));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(const ClearFavorites()),
      expect: () => [
        const FavoritesLoading(favorites: []),
        const FavoritesLoaded(favorites: []),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesLoading, FavoritesError] when GetFavorites fails',
      build: () {
        when(() => mockGetCachedFavoritesUseCase(NoParams()))
            .thenAnswer((_) async => Left(CacheFailure()));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(const GetFavorites()),
      expect: () => [
        const FavoritesLoading(favorites: []),
        FavoritesError(favorites: const [], failure: CacheFailure()),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesLoading, FavoritesError] when AddProduct fails',
      build: () {
        when(() => mockAddFavoritesUseCase(tFavoritesItemModel))
            .thenAnswer((_) async => Left(NetworkFailure()));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(AddProduct(favoritesItem: tFavoritesItemModel)),
      expect: () => [
        const FavoritesLoading(favorites: []),
        FavoritesError(favorites: const [], failure: NetworkFailure()),
      ],
    );
  });
}
