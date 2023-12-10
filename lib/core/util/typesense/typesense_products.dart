import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spoto/core/error/exceptions.dart';
import 'package:spoto/core/util/typesense/typesense_service.dart';
import 'package:spoto/data/models/product/product_model.dart';
import 'package:spoto/data/models/product/product_response_model.dart';
import 'package:spoto/domain/entities/product/product.dart';
import 'package:spoto/domain/usecases/product/get_product_usecase.dart';

class TypesenseProducts {
  TypesenseService typesenseService = TypesenseService();

  Future<ProductResponseModel> getProducts(FilterProductParams params) async {
    try {
      final foundProducts = typesenseService
          .searchProducts(params)
          .then((value) => productResponseModelFromMap(value));
      return foundProducts;
    } catch (e) {
      EasyLoading.showError("Failed to get products from Typesense: $e");
      throw ServerException(e.toString());
    }
  }

  Future<ProductResponseModel> createProduct(Product product) async {
    try {
      final productData = ProductModel.fromProduct(product).toJson();
      await typesenseService.createCollection();
      await typesenseService.createDocument(productData);
      Map<String, dynamic> updatedProducts =
          await typesenseService.searchProducts(
              const FilterProductParams(keyword: "", searchField: "name"));
      return productResponseModelFromMap(updatedProducts);
    } catch (e) {
      EasyLoading.showError("Failed to add product to Typesense: $e");
      throw ServerException(e.toString());
    }
  }

}
