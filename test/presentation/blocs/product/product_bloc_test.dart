import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:trudor/core/error/failures.dart';
import 'package:trudor/domain/entities/product/pagination_meta_data.dart';
import 'package:trudor/domain/usecases/product/add_product_usecase.dart';
import 'package:trudor/domain/usecases/product/get_product_usecase.dart';
import 'package:trudor/domain/usecases/product/update_product_usecase.dart';
import 'package:trudor/presentation/blocs/product/product_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/constant_objects.dart';

class MockGetProductUseCase extends Mock implements GetProductUseCase {}

class MockAddProductUseCase extends Mock implements AddProductUseCase {}

class MockUpdateProductUseCase extends Mock implements UpdateProductUseCase {}

void main() {
  group('ProductBloc', () {
    late ProductBloc productBloc;
    late MockGetProductUseCase mockGetProductUseCase;
    late MockAddProductUseCase mockAddProductUseCase;
    late MockUpdateProductUseCase mockUpdateProductUseCase;

    setUp(() {
      mockGetProductUseCase = MockGetProductUseCase();
      mockAddProductUseCase = MockAddProductUseCase();
      mockUpdateProductUseCase = MockUpdateProductUseCase();
      productBloc = ProductBloc(mockGetProductUseCase, mockAddProductUseCase,
          mockUpdateProductUseCase);
    });

    test('initial state should be ProductInitial', () {
      expect(
          productBloc.state,
          ProductInitial(
            products: const [],
            params: tFilterProductParams,
            metaData: PaginationMetaData(
              pageSize: 20,
              limit: 0,
              total: 0,
            ),
          ));
    });

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductLoaded] when GetProducts is added',
      build: () {
        when(() => mockGetProductUseCase(tFilterProductParams))
            .thenAnswer((_) async => Right(tProductResponseModel));
        return productBloc;
      },
      act: (bloc) => bloc.add(const GetProducts(tFilterProductParams)),
      expect: () => [
        ProductLoading(
          products: const [],
          metaData: PaginationMetaData(
            pageSize: 20,
            limit: 0,
            total: 0,
          ),
          params: tFilterProductParams,
        ),
        ProductLoaded(
          metaData: PaginationMetaData(
            pageSize: 20,
            limit: 10,
            total: 100,
          ),
          products: [tProductModel, tProductModel],
          params: tFilterProductParams,
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when GetProducts fails',
      build: () {
        when(() => mockGetProductUseCase(tFilterProductParams))
            .thenAnswer((_) async => Left(NetworkFailure()));
        return productBloc;
      },
      act: (bloc) => bloc.add(const GetProducts(tFilterProductParams)),
      expect: () => [
        ProductLoading(
          products: const [],
          metaData: PaginationMetaData(
            pageSize: 20,
            limit: 0,
            total: 0,
          ),
          params: tFilterProductParams,
        ),
        ProductError(
          products: const [],
          metaData: PaginationMetaData(
            pageSize: 20,
            limit: 0,
            total: 0,
          ),
          failure: NetworkFailure(),
          params: tFilterProductParams,
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductLoaded] when GetMoreProducts is added and there are no more products to load',
      build: () {
        when(() => mockGetProductUseCase(tFilterProductParams))
            .thenAnswer((_) async => Right(tProductResponseModel));
        return productBloc;
      },
      act: (bloc) => bloc.add(const GetMoreProducts()),
      expect: () => [],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when GetMoreProducts fails',
      build: () {
        when(() => mockGetProductUseCase(tFilterProductParams))
            .thenAnswer((_) async => Left(NetworkFailure()));
        return productBloc;
      },
      act: (bloc) => bloc.add(const GetMoreProducts()),
      expect: () => [],
    );
  });
}
