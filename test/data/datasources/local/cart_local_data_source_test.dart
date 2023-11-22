import 'package:trudor/core/error/failures.dart';
import 'package:trudor/data/data_sources/local/favorites_local_data_source.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/constant_objects.dart';
import '../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late FavoritesLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource =
        FavoritesLocalDataSourceImpl(sharedPreferences: mockSharedPreferences);
  });

  group('getFavorites', () {
    test('should return favorites items from SharedPreferences', () async {
      /// Arrange
      final favoritesItems = [tFavoritesItemModel];
      final String jsonString = fixture('favorites/favorites_item_list.json');
      when(() => mockSharedPreferences.getString(cachedFavorites))
          .thenReturn(jsonString);

      /// Act
      final result = await dataSource.getFavorites();

      /// Assert
      expect(result, equals(favoritesItems));
    });

    test('should return null when no favorites items are cached', () async {
      /// Arrange
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);

      /// Act and Assert
      expect(() => dataSource.getFavorites(), throwsA(isA<CacheFailure>()));
      verify(() => mockSharedPreferences.getString(any())).called(1);
    });
  });

  group('cacheFavorites', () {
    test('should cache favorites items in SharedPreferences', () async {
      /// Arrange
      final favorites = [tFavoritesItemModel];
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) => Future.value(true));

      /// Act
      await dataSource.saveFavorites(favorites);

      /// Assert
      verify(() => mockSharedPreferences.setString(any(), any())).called(1);
    });
  });

  group('cacheFavoritesItem', () {
    test('should add a new favorites item to the existing favorites and cache it',
        () async {
      /// Arrange
      final favoritesItemToAdd = tFavoritesItemModel;
      final String jsonString = fixture('favorites/favorites_item_list.json');
      when(() => mockSharedPreferences.getString(cachedFavorites))
          .thenReturn(jsonString);
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) => Future.value(true));

      /// Act
      await dataSource.saveFavoritesItem(favoritesItemToAdd);

      /// Assert
      verify(() => mockSharedPreferences.setString(any(), any())).called(1);
    });
  });

  group('clearFavorites', () {
    test('should remove cached favorites items from SharedPreferences', () async {
      /// Arrange
      when(() => mockSharedPreferences.remove(any()))
          .thenAnswer((_) async => true);

      /// Act
      final result = await dataSource.clearFavorites();

      /// Assert
      expect(result, isTrue);
    });
  });
}
