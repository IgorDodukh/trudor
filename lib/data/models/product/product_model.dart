import 'package:spoto/core/constant/collections.dart';

import '../../../domain/entities/product/product.dart';
import '../category/category_model.dart';
import 'price_tag_model.dart';

class ProductModel extends Product {
  const ProductModel({
    required String id,
    required String? ownerId,
    required bool? isNew,
    required ProductStatus? status,
    required String name,
    required num price,
    required String description,
    required List<PriceTagModel> priceTags,
    // required List<CategoryModel> categories,
    required String category,
    required List<String> images,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          ownerId: ownerId,
          isNew: isNew,
          status: status,
          name: name,
          price: price,
          description: description,
          priceTags: priceTags,
          // categories: categories,
          category: category,
          images: images,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory ProductModel.fromProduct(Product product) => ProductModel(
        id: product.id,
        ownerId: product.ownerId,
        isNew: product.isNew,
        status: product.status,
        name: product.name,
        price: product.price,
        description: product.description,
        priceTags: product.priceTags
            .map((priceTag) => PriceTagModel.fromPriceTag(priceTag))
            .toList(),
        // categories: product.categories
        //     .map((category) => CategoryModel.fromCategory(category))
        //     .toList(),
        category: product.category,
        images: product.images,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
  );

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json["_id"],
        ownerId: json["ownerId"],
        isNew: json["isNew"],
        status: ProductStatus.values.firstWhere((e) => e.toString() == 'ProductStatus.${json["status"]}'),
        name: json["name"],
        price: json["price"] ?? 0,
        description: json["description"],
        priceTags: List<PriceTagModel>.from(
            json["priceTags"].map((x) => PriceTagModel.fromJson(x))),
        // categories: List<CategoryModel>.from(
        //     json["categories"].map((x) => CategoryModel.fromJson(x))),
        category: json["category"],
        images: List<String>.from(json["images"].map((x) => x)),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "ownerId": ownerId,
        "isNew": isNew,
        "status": status!.name.toString(),
        "name": name,
        "price": price,
        "description": description,
        "priceTags": List<dynamic>.from(
            (priceTags as List<PriceTagModel>).map((x) => x.toJson())),
        // "categories": List<dynamic>.from(
        //     (categories as List<CategoryModel>).map((x) => x.toJson())),
        "category": category,
        "images": List<dynamic>.from(images.map((x) => x)),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };

  factory ProductModel.fromEntity(Product entity) => ProductModel(
        id: entity.id,
        ownerId: entity.ownerId,
        isNew: entity.isNew,
        status: entity.status,
        name: entity.name,
        price: entity.price,
        description: entity.description,
        priceTags: entity.priceTags
            .map((priceTag) => PriceTagModel.fromEntity(priceTag))
            .toList(),
        // categories: entity.categories
        //     .map((category) => CategoryModel.fromEntity(category))
        //     .toList(),
        category: entity.category,
        images: entity.images,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}
