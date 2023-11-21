import 'package:trudor/core/error/failures.dart';
import 'package:trudor/data/data_sources/local/delivery_info_local_data_source.dart';
import 'package:trudor/data/models/user/delivery_info_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/constant_objects.dart';
import '../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late DeliveryInfoLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = DeliveryInfoLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group('getDeliveryInfo', () {
    test('should return a list of DeliveryInfoModel from SharedPreferences',
        () async {
      /// Arrange
      final jsonString = fixture('delivery_info/delivery_info_list.json');
      when(() => mockSharedPreferences.getString(cashedDeliveryInfo))
          .thenReturn(jsonString);

      /// Act
      final result = await dataSource.getDeliveryInfo();

      /// Assert
      expect(result, isA<List<DeliveryInfoModel>>());
    }, skip: true);

    test('should throw CacheFailure when SharedPreferences returns null', () {
      /// Arrange
      when(() => mockSharedPreferences.getString(cashedDeliveryInfo))
          .thenReturn(null);

      /// Act
      final call = dataSource.getDeliveryInfo;

      /// Assert
      expect(() => call(), throwsA(isA<CacheFailure>()));
    });
  });

  group('saveDeliveryInfo', () {
    test('should call SharedPreferences.setString with the correct arguments',
        () async {
      /// Arrange
      const deliveryInfo = tDeliveryInfoModel;
      when(() => mockSharedPreferences.setString(
              cashedDeliveryInfo, deliveryInfoModelListToJson([deliveryInfo])))
          .thenAnswer((invocation) => Future<bool>.value(true));

      /// Act
      await dataSource.saveDeliveryInfo(deliveryInfo);

      /// Assert
      verify(() => mockSharedPreferences.setString(
          cashedDeliveryInfo, deliveryInfoModelListToJson([deliveryInfo])));
    });
  });

  group('updateDeliveryInfo', () {
    test('should call SharedPreferences.setString with the correct arguments',
        () async {
      /// Arrange
      final jsonString = fixture('delivery_info/delivery_info_list.json');
      when(() => mockSharedPreferences.getString(cashedDeliveryInfo))
          .thenReturn(jsonString);
      when(() => mockSharedPreferences.setString(cashedDeliveryInfo,
              deliveryInfoModelListToJson([tDeliveryInfoModel])))
          .thenAnswer((invocation) => Future<bool>.value(true));

      /// Act
      await dataSource.updateDeliveryInfo(tDeliveryInfoModel);

      /// Assert
      verify(() => mockSharedPreferences.setString(cashedDeliveryInfo,
          deliveryInfoModelListToJson([tDeliveryInfoModel])));
    }, skip: true);
  });

  group('updateSelectedDeliveryInfo', () {
    test('should call SharedPreferences.setString with the correct arguments',
        () async {
      /// Arrange
      when(() => mockSharedPreferences.setString(cachedSelectedDeliveryInfo,
              deliveryInfoModelToJson(tDeliveryInfoModel)))
          .thenAnswer((invocation) => Future<bool>.value(true));

      /// Act
      await dataSource.updateSelectedDeliveryInfo(tDeliveryInfoModel);

      /// Assert
      verify(() => mockSharedPreferences.setString(cachedSelectedDeliveryInfo,
          deliveryInfoModelToJson(tDeliveryInfoModel)));
    });
  });

  group('getSelectedDeliveryInfo', () {
    test('should call SharedPreferences.getString with the correct arguments',
        () async {
      /// Arrange
      final jsonString = fixture('delivery_info/delivery_info.json');
      when(() => mockSharedPreferences.getString(cachedSelectedDeliveryInfo))
          .thenReturn(jsonString);

      /// Act
      await dataSource.getSelectedDeliveryInfo();

      /// Assert
      verify(() => mockSharedPreferences.getString(cachedSelectedDeliveryInfo));
    }, skip: true);

    test('should throw CacheFailure when SharedPreferences returns null', () {
      /// Arrange
      when(() => mockSharedPreferences.getString(cashedDeliveryInfo))
          .thenReturn(null);
      final call = dataSource.getSelectedDeliveryInfo;

      /// Assert and Act
      expect(() => call(), throwsA(isA<CacheFailure>()));
    });
  });
}
