import 'package:firebase_storage/firebase_storage.dart';
import 'package:spoto/core/util/firestore/firestore_favorites.dart';

import '../../models/favorites/favorites_item_model.dart';

abstract class FavoritesFirebaseDataSource {
  Future<FavoritesItemModel> addToFavorites(FavoritesItemModel favoritesItem);

  Future<FavoritesItemModel> removeFromFavorites(
      FavoritesItemModel favoritesItem);

  Future<List<FavoritesItemModel>> syncFavorites(String userId);
}

class FavoritesFirebaseDataSourceSourceImpl
    implements FavoritesFirebaseDataSource {
  final FirebaseStorage storage;

  FavoritesFirebaseDataSourceSourceImpl({required this.storage});

  @override
  Future<FavoritesItemModel> addToFavorites(
      FavoritesItemModel favoritesItem) async {
    FirestoreFavorites firestoreService = FirestoreFavorites();
    firestoreService.addProductToFavorites(favoritesItem);
    return favoritesItem;
  }

  @override
  Future<FavoritesItemModel> removeFromFavorites(
      FavoritesItemModel favoritesItem) async {
    FirestoreFavorites firestoreService = FirestoreFavorites();
    firestoreService.removeProductFromFavorites(favoritesItem);
    return favoritesItem;
  }

  @override
  Future<List<FavoritesItemModel>> syncFavorites(String userId) async {
    FirestoreFavorites firestoreService = FirestoreFavorites();
    return firestoreService.getProductsFromFavorites(userId);
  }
}
