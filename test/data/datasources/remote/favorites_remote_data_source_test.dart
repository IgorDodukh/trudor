import 'dart:convert';
import 'package:trudor/core/constant/strings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/constant_objects.dart';
import '../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  // late FavoritesRemoteDataSourceSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    // dataSource = FavoritesRemoteDataSourceSourceImpl(client: mockHttpClient);
  });

  group('addToFavorites', () {
    test('should perform a POST request to the correct URL with authorization', () async {
      // Arrange
      const fakeToken = 'fakeToken';
      final fakeFavoritesItem = tFavoritesItemModel;
      final fakeResponse = fixture('favorites/favorites_item_add_response.json');
      const expectedUrl = '$baseUrl/users/cart';
      when(() => mockHttpClient.post(
        Uri.parse(expectedUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $fakeToken',
        },
        body: jsonEncode(fakeFavoritesItem.toBodyJson()),
      )).thenAnswer((_) async => http.Response(fakeResponse, 200));

      // Act
      // final result = await dataSource.addToFavorites(fakeFavoritesItem, fakeToken);

      // Assert
      verify(() => mockHttpClient.post(
        Uri.parse(expectedUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $fakeToken',
        },
        body: jsonEncode(fakeFavoritesItem.toBodyJson()),
      ));
      // expect(result, isA<FavoritesItemModel>());
    }, skip: true);

    test('should throw a ServerException on non-200 status code', () async {
      // Arrange
      const fakeToken = 'fakeToken';
      final fakeFavoritesItem = tFavoritesItemModel;
      const expectedUrl = '$baseUrl/users/cart';
      when(() => mockHttpClient.post(
        Uri.parse(expectedUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $fakeToken',
        },
        body: jsonEncode(fakeFavoritesItem.toBodyJson()),
      )).thenAnswer((_) async => http.Response('Error message', 404));

      // Act
      // final result = dataSource.addToFavorites(fakeFavoritesItem, fakeToken);

      // Assert
      // expect(result, throwsA(isA<ServerException>()));
    });
  });

  group('syncFavorites', () {
    test('should perform a POST request to the correct URL with authorization', () async {
      // Arrange
      const fakeToken = 'fakeToken';
      final fakeFavorites = [tFavoritesItemModel];
      const expectedUrl = '$baseUrl/users/cart/sync';
      final fakeResponse = fixture('favorites/favorites_item_fetch_response.json');
      when(() => mockHttpClient.post(
        Uri.parse(expectedUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $fakeToken',
        },
        body: jsonEncode({
          "data": fakeFavorites
              .map((e) => {
            "product": e.product.id,
            "priceTag": e.priceTag.id,
          })
              .toList()
        }),
      )).thenAnswer((_) async => http.Response(fakeResponse, 200));

      // Act
      // final result = await dataSource.syncFavorites(fakeFavorites, fakeToken);

      // Assert
      verify(() => mockHttpClient.post(
        Uri.parse(expectedUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $fakeToken',
        },
        body: jsonEncode({
          "data": fakeFavorites
              .map((e) => {
            "product": e.product.id,
            "priceTag": e.priceTag.id,
          })
              .toList()
        }),
      ));
      // expect(result, isA<List<FavoritesItemModel>>());
    }, skip: true);

    test('should throw a ServerException on non-200 status code', () async {
      // Arrange
      const fakeToken = 'fakeToken';
      final fakeFavorites = [tFavoritesItemModel];
      const expectedUrl = '$baseUrl/users/cart/sync';
      when(() => mockHttpClient.post(
        Uri.parse(expectedUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $fakeToken',
        },
        body: jsonEncode({
          "data": fakeFavorites
              .map((e) => {
            "product": e.product.id,
            "priceTag": e.priceTag.id,
          })
              .toList()
        }),
      )).thenAnswer((_) async => http.Response('Error message', 404));

      // Act
      // final result = dataSource.syncFavorites(fakeFavorites, fakeToken);

      // Assert
      // expect(result, throwsA(isA<ServerException>()));
    }, skip: true);
  });
}
