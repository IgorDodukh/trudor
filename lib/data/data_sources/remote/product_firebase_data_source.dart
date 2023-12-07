import 'package:spoto/core/util/firstore_folder_methods.dart';
import 'package:spoto/data/models/product/product_model.dart';
import 'package:spoto/data/models/product/product_response_model.dart';
import 'package:spoto/domain/entities/product/product.dart';
import 'package:spoto/domain/usecases/product/get_product_usecase.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class ProductFirebaseDataSource {
  Future<ProductResponseModel> getProducts(FilterProductParams params);
  Future<void> addProduct(ProductModel product);
  Future<ProductResponseModel> updateProduct(Product product);
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
  Future<void> addProduct(ProductModel product) async {
    FirestoreService firestoreService = FirestoreService();
    firestoreService.createProduct(product);
  }

  @override
  Future<ProductResponseModel> updateProduct(Product product) async {
    FirestoreService firestoreService = FirestoreService();
    return await firestoreService.updateProduct(product);
  }
}
