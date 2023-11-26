import 'dart:convert';

import '../../../domain/entities/favorites/favorites_item.dart';
import '../product/price_tag_model.dart';
import '../product/product_model.dart';

List<FavoritesItemModel> favoritesItemModelListFromLocalJson(String str) =>
    List<FavoritesItemModel>.from(
        json.decode(str).map((x) => FavoritesItemModel.fromJson(x)));

List<FavoritesItemModel> favoritesItemModelListFromRemoteJson(String str) =>
    List<FavoritesItemModel>.from(
        json.decode(str)["data"].map((x) => FavoritesItemModel.fromJson(x)));

List<FavoritesItemModel> favoritesItemModelFromJson(String str) =>
    List<FavoritesItemModel>.from(
        json.decode(str).map((x) => FavoritesItemModel.fromJson(x)));

String favoritesItemModelToJson(List<FavoritesItemModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FavoritesItemModel extends ListViewItem {
  const FavoritesItemModel({
    String? id,
    String? addedAt,
    String? userId,
    required ProductModel product,
    required PriceTagModel priceTag,
  }) : super(id: id, product: product, priceTag: priceTag, addedAt: addedAt, userId: userId);

  factory FavoritesItemModel.fromJson(Map<String, dynamic> json) {
    return FavoritesItemModel(
      id: json["_id"],
      product: ProductModel.fromJson(json["product"]),
      priceTag: PriceTagModel.fromJson(json["priceTag"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "product": (product as ProductModel).toJson(),
        "priceTag": (priceTag as PriceTagModel).toJson(),
        "addedAt": addedAt,
        "userId": userId,
      };

  Map<String, dynamic> toBodyJson() => {
        "_id": id,
        "product": product.id,
        "priceTag": priceTag.id,
        "addedAt": addedAt,
        "userId": userId,
      };

  factory FavoritesItemModel.fromParent(ListViewItem favoritesItem) {
    return FavoritesItemModel(
      id: favoritesItem.id,
      product: favoritesItem.product as ProductModel,
      priceTag: favoritesItem.priceTag as PriceTagModel,
      addedAt: favoritesItem.addedAt,
      userId: favoritesItem.userId,
    );
  }
}
