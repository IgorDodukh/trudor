import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/entities/product/pagination_meta_data.dart';
import '../../../domain/entities/product/product.dart';
import '../../../domain/entities/product/product_response.dart';
import 'pagination_data_model.dart';
import 'product_model.dart';
import 'dart:convert';

ProductResponseModel productResponseModelFromJson(String str) =>
    ProductResponseModel.fromJson(json.decode(str));

ProductResponseModel productResponseModelFromFirestore(QuerySnapshot querySnapshot) =>
    ProductResponseModel.fromFirebase(querySnapshot);

ProductResponseModel productResponseModelFromMap(Map<String, dynamic> result) =>
    ProductResponseModel.fromMap(result);

String productResponseModelToJson(ProductResponseModel data) =>
    json.encode(data.toJson());

class ProductResponseModel extends ProductResponse {
  ProductResponseModel({
    required PaginationMetaData meta,
    required List<Product> data,
  }) : super(products: data, paginationMetaData: meta);

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) =>
      ProductResponseModel(
        meta: PaginationMetaDataModel.fromJson(json["meta"]),
        data: List<ProductModel>.from(
            json["data"].map((x) => ProductModel.fromJson(x))),
      );

  factory ProductResponseModel.fromFirebase(QuerySnapshot querySnapshot) =>
      ProductResponseModel(
        meta: PaginationMetaDataModel(
          pageSize: 20,
          total: 0,
          page: 1,
        ),
        data: List<ProductModel>.from(
            querySnapshot.docs.map((x) => ProductModel.fromJson(x.data() as Map<String, dynamic>))),
  );

  factory ProductResponseModel.fromMap(Map<String, dynamic> result) =>
      ProductResponseModel(
        meta: PaginationMetaDataModel(
          pageSize: result["request_params"]["per_page"],
          total: result["found"],
          page: result["page"],
        ),
        data: List<ProductModel>.from(
            result["hits"].map((x) => ProductModel.fromJson(x["document"] as Map<String, dynamic>))),
  );

  Map<String, dynamic> toJson() => {
        "meta": (paginationMetaData as PaginationMetaDataModel).toJson(),
        "data": List<dynamic>.from((products as List<ProductModel>).map((x) => x.toJson())),
      };
}
