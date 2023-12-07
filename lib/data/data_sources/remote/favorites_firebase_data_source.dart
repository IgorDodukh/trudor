
import 'package:spoto/core/util/firstore_folder_methods.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/favorites/favorites_item_model.dart';

abstract class FavoritesFirebaseDataSource {
  Future<FavoritesItemModel> addToFavorites(FavoritesItemModel favoritesItem);
  Future<FavoritesItemModel> removeFromFavorites(FavoritesItemModel favoritesItem);
  Future<List<FavoritesItemModel>> syncFavorites(List<FavoritesItemModel> favorites);
}

class FavoritesFirebaseDataSourceSourceImpl implements FavoritesFirebaseDataSource {
  final FirebaseStorage storage;

  FavoritesFirebaseDataSourceSourceImpl({required this.storage});

  @override
  Future<FavoritesItemModel> addToFavorites(FavoritesItemModel favoritesItem) async {
    FirestoreService firestoreService = FirestoreService();
    firestoreService.addProductToFavorites(favoritesItem);
    return favoritesItem;
  }

  @override
  Future<FavoritesItemModel> removeFromFavorites(FavoritesItemModel favoritesItem) async {
    FirestoreService firestoreService = FirestoreService();
    firestoreService.removeProductFromFavorites(favoritesItem);
    return favoritesItem;
  }

  @override
  Future<List<FavoritesItemModel>> syncFavorites(
      List<FavoritesItemModel> favorites) async {

    for (final favoritesItem in favorites) {
      final reference = storage.ref('users/${favoritesItem.userId}/favorites/${favoritesItem.product.id}');
      // reference.set(reference, jsonEncode(favoritesItem.toBodyJson()));
    }
    return favorites;
  }
}
