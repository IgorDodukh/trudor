part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
}

class GetProducts extends ProductEvent {
  final FilterProductParams params;
  const GetProducts(this.params);

  @override
  List<Object> get props => [];
}

class AddProduct extends ProductEvent {
  final Product params;
  const AddProduct(this.params);

  @override
  List<Object> get props => [];
}

class UpdateProduct extends ProductEvent {
  final UpdateProductParams params;
  const UpdateProduct(this.params);

  @override
  List<Object> get props => [];
}

class GetMoreProducts extends ProductEvent {
  final FilterProductParams params;
  const GetMoreProducts(this.params);
  @override
  List<Object> get props => [];
}
