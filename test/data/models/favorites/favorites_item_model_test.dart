import 'dart:convert';

import 'package:spoto/data/models/favorites/favorites_item_model.dart';
import 'package:spoto/domain/entities/favorites/favorites_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/constant_objects.dart';
import '../../../fixtures/fixture_reader.dart';

void main() {
  test(
    'FavoritesItemModel should be a subclass of FavoritesItem entity',
    () async {
      /// Assert
      expect(tFavoritesItemModel, isA<ListViewItem>());
    },
  );

  group('fromJson', () {
    test(
      '''Should successfully deserialize a JSON map into a FavoritesItemMap
          object and ensure that the resulting 
          object matches the expected tFavoritesItem''',
      () async {
        /// Arrange
        final Map<String, dynamic> jsonMap =
            json.decode(fixture('favorites/favorites_item.json'));

        /// Act
        final result = FavoritesItemModel.fromJson(jsonMap);

        /// Assert
        expect(result, tFavoritesItemModel);
      },
    );
  });

  group('toJson', () {
    test(
      'should return a JSON map containing the proper data',
      () async {
        /// Arrange
        final result = tFavoritesItemModel.toJson();

        /// Act
        final Map<String, dynamic> jsonMap =
            json.decode(fixture('favorites/favorites_item.json'));

        /// Assert
        expect(result, jsonMap);
      },
    );
  });
}
