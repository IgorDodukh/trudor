import 'package:dartz/dartz.dart';
import 'package:spoto/core/error/exceptions.dart';
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/core/network/network_info.dart';
import 'package:spoto/data/data_sources/local/product_local_data_source.dart';
import 'package:spoto/data/data_sources/remote/product_firebase_data_source.dart';
import 'package:spoto/data/data_sources/remote/product_remote_data_source.dart';
import 'package:spoto/data/repositories/product_repository_impl.dart';
import 'package:spoto/domain/usecases/product/get_product_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/constant_objects.dart';

class MockProductDataSource extends Mock implements ProductFirebaseDataSource {}
class MockRemoteDataSource extends Mock implements ProductRemoteDataSource {}

class MockLocalDataSource extends Mock implements ProductLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late ProductRepositoryImpl repository;
  late MockProductDataSource mockProductDataSource;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockProductDataSource = MockProductDataSource();
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
      firebaseDataSource: mockProductDataSource,
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
        when(() =>
                mockRemoteDataSource.getProducts(const FilterProductParams()))
            .thenAnswer((_) async => tProductResponseModel);
        when(() => mockLocalDataSource.saveProducts(tProductResponseModel))
            .thenAnswer((invocation) => Future<void>.value());

        /// Act
        // repository.getProducts();
        /// Assert
        // verify(() => mockNetworkInfo.isConnected);
      }, skip: true,
    );

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          /// Arrange
          when(() =>
                  mockRemoteDataSource.getProducts(const FilterProductParams()))
              .thenAnswer((_) async => tProductResponseModel);
          when(() => mockLocalDataSource.saveProducts(tProductResponseModel))
              .thenAnswer((invocation) => Future<void>.value());

          /// Act
          final actualResult =
              await repository.getProducts(const FilterProductParams());

          /// Assert
          actualResult.fold(
            (left) => fail('test failed'),
            (right) {
              verify(() => mockRemoteDataSource
                  .getProducts(const FilterProductParams()));
              expect(right, tProductResponseModel);
            },
          );
        }, skip: true,
      );

      test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
          /// Arrange
          when(() =>
                  mockRemoteDataSource.getProducts(const FilterProductParams()))
              .thenAnswer((_) async => tProductResponseModel);
          when(() => mockLocalDataSource.saveProducts(tProductResponseModel))
              .thenAnswer((invocation) => Future<void>.value());

          /// Act
          await repository.getProducts(const FilterProductParams());

          /// Assert
          verify(() =>
              mockRemoteDataSource.getProducts(const FilterProductParams()));
          verify(() => mockLocalDataSource.saveProducts(tProductResponseModel));
        }, skip: true,
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          /// Arrange
          when(() =>
                  mockRemoteDataSource.getProducts(const FilterProductParams()))
              .thenThrow(const ServerException(""));

          /// Act
          final result =
              await repository.getProducts(const FilterProductParams());

          /// Assert
          verify(() =>
              mockRemoteDataSource.getProducts(const FilterProductParams()));
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        }, skip: true,
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          /// Arrange
          when(() => mockLocalDataSource.getLastProducts())
              .thenAnswer((_) async => tProductResponseModel);

          /// Act
          final result =
              await repository.getProducts(const FilterProductParams());

          /// Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastProducts());
          expect(result, equals(Right(tProductResponseModel)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
        () async {
          /// Arrange
          when(() => mockLocalDataSource.getLastProducts())
              .thenThrow(const CacheException(""));

          /// Act
          final result =
              await repository.getProducts(const FilterProductParams());

          /// Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastProducts());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}
