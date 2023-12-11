import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spoto/core/error/exceptions.dart';
import 'package:spoto/core/util/firestore/firestore_products.dart';
import 'package:spoto/core/util/typesense/typesense_service.dart';
import 'package:spoto/data/models/favorites/favorites_item_model.dart';

class FirestoreFavorites {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirestoreProducts firestoreProducts = FirestoreProducts();
  TypesenseService typesenseService = TypesenseService();

  Future<List<FavoritesItemModel>> getProductsFromFavorites(
      String userId) async {
    try {
      List<FavoritesItemModel> productsList = [];
      final querySnapshot =
          await _firestore.collection('favorites').doc(userId).get();
      if (querySnapshot.exists) {
        final favoritesQuery = querySnapshot.data() as Map<String, dynamic>;
        for (String productId in favoritesQuery.keys) {
          if (favoritesQuery[productId] == true) {
            await firestoreProducts.getProduct(productId).then((value) => {
                  if (value["status"] == "active")
                    productsList
                        .add(FavoritesItemModel.fromFirestoreJson(value)),
                });
          }
        }
      }
      return productsList;
    } catch (e) {
      EasyLoading.showError("Failed to get from favorites: $e");
      throw ServerException(e.toString());
    }
  }

  Future<void> addProductToFavorites(FavoritesItemModel favoritesItem) async {
    try {
      DocumentReference productRef =
          _firestore.collection('favorites').doc(favoritesItem.userId);
      final snapshot = await productRef.get();
      if (!snapshot.exists) {
        productRef.set({favoritesItem.product.id: true});
      } else {
        await productRef.update({favoritesItem.product.id: true});
      }
    } catch (e) {
      EasyLoading.showError("Failed to add product to favorites: $e");
    }
  }

  Future<void> removeProductFromFavorites(
      FavoritesItemModel favoritesItem) async {
    try {
      DocumentReference productRef =
          _firestore.collection('favorites').doc(favoritesItem.userId);
      await productRef.update({favoritesItem.product.id: false});
    } catch (e) {
      EasyLoading.showError("Failed to remove product from favorites: $e");
    }
  }
}
