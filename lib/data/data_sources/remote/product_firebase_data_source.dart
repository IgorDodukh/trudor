import 'package:eshop/core/util/firstore_folder_methods.dart';
import 'package:eshop/data/models/product/product_model.dart';
import 'package:eshop/data/models/product/product_response_model.dart';
import 'package:eshop/domain/usecases/product/get_product_usecase.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class ProductFirebaseDataSource {
  Future<ProductResponseModel> getProducts(FilterProductParams params);
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
}

class ProductFirebaseDataSourceSourceImpl implements ProductFirebaseDataSource {
  final FirebaseStorage storage;

  ProductFirebaseDataSourceSourceImpl({required this.storage});

  @override
  Future<ProductResponseModel> getProducts(FilterProductParams params) async {
    FirestoreService firestoreService = FirestoreService();
    return await firestoreService.getProducts(params);
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    FirestoreService firestoreService = FirestoreService();
    firestoreService.createProduct(product);
    return product;
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    FirestoreService firestoreService = FirestoreService();
    firestoreService.updateProduct(product);
    return product;
  }
}
