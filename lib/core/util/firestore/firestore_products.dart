import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spoto/core/error/exceptions.dart';
import 'package:spoto/core/util/typesense/typesense_service.dart';
import 'package:spoto/data/models/product/product_model.dart';
import 'package:spoto/data/models/product/product_response_model.dart';
import 'package:spoto/domain/entities/product/product.dart';
import 'package:spoto/domain/usecases/product/get_product_usecase.dart';

class FirestoreProducts {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TypesenseService typesenseService = TypesenseService();

  Future<void> createProduct(Product product) async {
    try {
      final productData = ProductModel.fromProduct(product).toJson();

      DocumentReference productRef = _firestore.collection('products').doc(productData['_id']);
      await productRef.set(productData);

    } catch (e) {
      EasyLoading.showError("Failed to add product: $e");
      throw ServerException(e.toString());
    }
  }

  Future<ProductResponseModel> updateProduct(Product product) async {
    try {
      final productData = ProductModel.fromProduct(product).toJson();
      await typesenseService.updateDocument(productData);
      DocumentReference productRef =
          _firestore.collection('products').doc(productData['_id']);
      await productRef.update(productData);

      Map<String, dynamic> updatedProducts =
          await typesenseService.searchProducts(
              const FilterProductParams(keyword: "", searchField: "name"));
      return productResponseModelFromMap(updatedProducts);
    } catch (e) {
      EasyLoading.showError("Failed to update product: $e");
      throw ServerException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data;
      } else {
        throw Exception("Product not found by id $productId");
      }
    } catch (e) {
      EasyLoading.showError("Failed to get product details: $e");
      throw ServerException(e.toString());
    }
  }

  Future<ProductResponseModel> getProducts(FilterProductParams params) async {
    try {
      CollectionReference productsCollection =
      _firestore.collection('products');
      Query productsQuery = productsCollection;

      if (params.keyword != null && params.keyword!.isNotEmpty) {
        productsQuery =
            productsQuery.where('name', isGreaterThanOrEqualTo: params.keyword);
      }
      QuerySnapshot querySnapshot = await productsQuery.get();
      return productResponseModelFromFirestore(querySnapshot);
    } catch (e) {
      EasyLoading.showError("Failed to get products: $e");
      throw ServerException(e.toString());
    }
  }
}
