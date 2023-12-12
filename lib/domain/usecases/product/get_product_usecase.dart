import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/category/category.dart';
import '../../entities/product/product_response.dart';
import '../../repositories/product_repository.dart';

class GetProductUseCase
    implements UseCase<ProductResponse, FilterProductParams> {
  final ProductRepository repository;

  GetProductUseCase(this.repository);

  @override
  Future<Either<Failure, ProductResponse>> call(
      FilterProductParams params) async {
    return await repository.getProducts(params);
  }
}

class FilterProductParams {
  final String? keyword;
  final String? searchField;
  final String? status;
  final String? sortBy;
  final String? sortOrder;
  final List<Category> categories;
  final double? minPrice;
  final double? maxPrice;
  final int? limit;
  final int? pageSize;

  const FilterProductParams({
    this.keyword = '',
    this.status = '',
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
    this.searchField = 'name',
    this.categories = const [],
    this.minPrice,
    this.maxPrice,
    this.limit = 0,
    this.pageSize = 10,
  });

  FilterProductParams copyWith({
    int? skip,
    String? keyword,
    String? status,
    String? sortBy,
    String? sortOrder,
    String? searchField,
    List<Category>? categories,
    double? minPrice,
    double? maxPrice,
    int? limit,
    int? pageSize,
  }) =>
      FilterProductParams(
        keyword: keyword ?? this.keyword,
        status: status ?? this.status,
        sortBy: sortBy ?? this.sortBy,
        sortOrder: sortOrder ?? this.sortOrder,
        searchField: searchField ?? this.searchField,
        categories: categories ?? this.categories,
        minPrice: minPrice,
        maxPrice: maxPrice,
        limit: skip ?? this.limit,
        pageSize: pageSize ?? this.pageSize,
      );
}
