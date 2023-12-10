import 'package:firebase_storage/firebase_storage.dart';
import 'package:spoto/core/util/firestore/firestore_products.dart';
import 'package:spoto/core/util/typesense/typesense_products.dart';
import 'package:spoto/data/models/product/product_response_model.dart';
import 'package:spoto/domain/entities/product/product.dart';
import 'package:spoto/domain/usecases/product/get_product_usecase.dart';

abstract class ProductFirebaseDataSource {
  Future<ProductResponseModel> getProducts(FilterProductParams params);

  Future<ProductResponseModel> addProduct(Product product);

  Future<ProductResponseModel> updateProduct(Product product);
}

class ProductFirebaseDataSourceSourceImpl implements ProductFirebaseDataSource {
  final FirebaseStorage storage;

  ProductFirebaseDataSourceSourceImpl({required this.storage});

  @override
  Future<ProductResponseModel> getProducts(FilterProductParams params) async {
    TypesenseProducts typesenseProducts = TypesenseProducts();
    return await typesenseProducts.getProducts(params);
  }

  @override
  Future<ProductResponseModel> addProduct(Product product) async {
    FirestoreProducts firestoreService = FirestoreProducts();
    await firestoreService.createProduct(product);

    TypesenseProducts typesenseService = TypesenseProducts();
    return await typesenseService.createProduct(product);
  }

  @override
  Future<ProductResponseModel> updateProduct(Product product) async {
    FirestoreProducts firestoreService = FirestoreProducts();
    return await firestoreService.updateProduct(product);
  }
}
