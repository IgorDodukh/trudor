import 'package:spoto/core/error/failures.dart';
import 'package:spoto/core/network/network_info.dart';
import 'package:spoto/data/data_sources/local/favorites_local_data_source.dart';
import 'package:spoto/data/data_sources/local/user_local_data_source.dart';
import 'package:spoto/data/data_sources/remote/favorites_firebase_data_source.dart';
import 'package:spoto/data/repositories/favorites_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/constant_objects.dart';

class MockRemoteDataSource extends Mock implements FavoritesFirebaseDataSource {}

class MockLocalDataSource extends Mock implements FavoritesLocalDataSource {}

class MockUserLocalDataSource extends Mock implements UserLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late FavoritesRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockUserLocalDataSource mockUserLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockUserLocalDataSource = MockUserLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = FavoritesRepositoryImpl(
      firebaseDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
      userLocalDataSource: mockUserLocalDataSource,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreted', () {
    test(
      'should check if the device is online',
      () async {
        /// Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockUserLocalDataSource.isTokenAvailable())
            .thenAnswer((invocation) => Future.value(true));
        when(() => mockUserLocalDataSource.getToken())
            .thenAnswer((invocation) => Future.value('token'));
        when(() => mockRemoteDataSource.syncFavorites("id"))
            .thenAnswer((_) async => [tFavoritesItemModel]);
        when(() => mockLocalDataSource.getFavorites())
            .thenAnswer((_) async => [tFavoritesItemModel]);
        when(() => mockLocalDataSource.saveFavorites([tFavoritesItemModel]))
            .thenAnswer((invocation) => Future<void>.value());

        /// Act
        repository.syncFavorites();

        /// Assert
        verify(() => mockNetworkInfo.isConnected);
      },
    );
  });

  runTestsOnline(() {
    group('syncFavorites', () {
      test(
        'should return remote data when the call to remote sync Favorites data source is successful',
        () async {
          /// Arrange
          when(() => mockUserLocalDataSource.isTokenAvailable())
              .thenAnswer((invocation) => Future.value(true));
          when(() => mockUserLocalDataSource.getToken())
              .thenAnswer((invocation) => Future.value('token'));
          when(() => mockRemoteDataSource.syncFavorites("id"))
              .thenAnswer((_) async => [tFavoritesItemModel]);
          when(() => mockLocalDataSource.getFavorites())
              .thenAnswer((_) async => [tFavoritesItemModel]);
          when(() => mockLocalDataSource.saveFavorites([tFavoritesItemModel]))
              .thenAnswer((invocation) => Future<void>.value());

          /// Act
          final actualResult = await repository.syncFavorites();

          /// Assert
          actualResult.fold(
            (left) => fail('test failed'),
            (right) => expect(right, [tFavoritesItemModel]),
          );
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
          /// Arrange
          when(() => mockUserLocalDataSource.isTokenAvailable())
              .thenAnswer((invocation) => Future.value(true));
          when(() => mockUserLocalDataSource.getToken())
              .thenAnswer((invocation) => Future.value('token'));
          when(() => mockRemoteDataSource.syncFavorites("id"))
              .thenAnswer((_) async => [tFavoritesItemModel]);
          when(() => mockLocalDataSource.getFavorites())
              .thenAnswer((_) async => [tFavoritesItemModel]);
          when(() => mockLocalDataSource.saveFavorites([tFavoritesItemModel]))
              .thenAnswer((invocation) => Future<void>.value());

          /// Act
          await repository.syncFavorites();

          /// Assert
          verify(() => mockLocalDataSource.saveFavorites([tFavoritesItemModel]));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          /// Arrange
          when(() => mockUserLocalDataSource.isTokenAvailable())
              .thenAnswer((invocation) => Future.value(true));
          when(() => mockUserLocalDataSource.getToken())
              .thenAnswer((invocation) => Future.value('token'));
          when(() => mockRemoteDataSource.syncFavorites("id"))
              .thenThrow(ServerFailure());
          when(() => mockLocalDataSource.getFavorites())
              .thenAnswer((_) async => [tFavoritesItemModel]);
          when(() => mockLocalDataSource.saveFavorites([tFavoritesItemModel]))
              .thenAnswer((invocation) => Future<void>.value());

          /// Act
          final result = await repository.syncFavorites();

          /// Assert
          result.fold(
            (left) => expect(left, ServerFailure()),
            (right) => fail('test failed'),
          );
        },
      );

      test(
        'should sync remote Favorites successfully when the call to local data source is unsuccessful',
        () async {
          /// Arrange
          when(() => mockUserLocalDataSource.isTokenAvailable())
              .thenAnswer((invocation) => Future.value(true));
          when(() => mockUserLocalDataSource.getToken())
              .thenAnswer((invocation) => Future.value('token'));
          when(() => mockRemoteDataSource.syncFavorites(""))
              .thenAnswer((_) async => [tFavoritesItemModel]);
          when(() => mockLocalDataSource.getFavorites()).thenThrow(CacheFailure());
          when(() => mockLocalDataSource.saveFavorites([tFavoritesItemModel]))
              .thenAnswer((invocation) => Future<void>.value());

          /// Act
          final result = await repository.syncFavorites();

          /// Assert
          result.fold(
            (left) => fail('test failed'),
            (right) => expect(right, [tFavoritesItemModel]),
          );
        },
      );
    });

    group('getCachedFavorites', () {
      test(
        'should return local cached Favorites items data when the call to local data source is successful',
        () async {
          /// Arrange
          when(() => mockLocalDataSource.getFavorites())
              .thenAnswer((_) async => [tFavoritesItemModel]);

          /// Act
          final actualResult = await repository.getCachedFavorites();

          /// Assert
          actualResult.fold(
            (left) => fail('test failed'),
            (right) => expect(right, [tFavoritesItemModel]),
          );
        },
      );

      test(
        'should return [CachedFailure] when the call to local data source is fail',
        () async {
          /// Arrange
          when(() => mockLocalDataSource.getFavorites()).thenThrow(CacheFailure());

          /// Act
          final actualResult = await repository.getCachedFavorites();

          /// Assert
          actualResult.fold(
            (left) => expect(left, CacheFailure()),
            (right) => fail('test failed'),
          );
        },
      );
    });

    test(
      'should return [FavoritesItem] when the call to [addToFavorites] remote method is successfully',
      () async {
        /// Arrange
        when(() => mockUserLocalDataSource.isTokenAvailable())
            .thenAnswer((invocation) => Future.value(true));
        when(() => mockUserLocalDataSource.getToken())
            .thenAnswer((invocation) => Future.value('token'));
        when(() => mockRemoteDataSource.addToFavorites(tFavoritesItemModel))
            .thenAnswer((_) async => tFavoritesItemModel);
        when(() => mockLocalDataSource.saveFavoritesItem(tFavoritesItemModel))
            .thenAnswer((invocation) => Future<void>.value());

        /// Act
        final actualResult = await repository.addToFavorites(tFavoritesItemModel);

        /// Assert
        actualResult.fold(
          (left) => fail('test failed'),
          (right) => expect(right, tFavoritesItemModel),
        );
      },
    );
  });

  runTestsOffline(() {
    test(
      'should return last locally cached data when the cached data is present',
      () async {
        /// Act
        final result = await repository.syncFavorites();

        /// Assert
        verifyZeroInteractions(mockRemoteDataSource);
        verifyZeroInteractions(mockLocalDataSource);
        result.fold(
          (left) => expect(left, NetworkFailure()),
          (right) => fail('test failed'),
        );
      },
    );

    test(
      'should return local cached data when the call to local data source is successful',
      () async {
        /// Arrange
        when(() => mockLocalDataSource.getFavorites())
            .thenAnswer((_) async => [tFavoritesItemModel]);

        /// Act
        final actualResult = await repository.getCachedFavorites();

        /// Assert
        actualResult.fold(
          (left) => fail('test failed'),
          (right) => expect(right, [tFavoritesItemModel]),
        );
      },
    );

    test(
      'should return [CachedFailure] when the call to local data source is fail',
      () async {
        /// Arrange
        when(() => mockLocalDataSource.getFavorites()).thenThrow(CacheFailure());

        /// Act
        final actualResult = await repository.getCachedFavorites();

        /// Assert
        actualResult.fold(
          (left) => expect(left, CacheFailure()),
          (right) => fail('test failed'),
        );
      },
    );
  });
}
