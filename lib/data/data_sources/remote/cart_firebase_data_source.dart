
import 'package:eshop/core/util/firstore_folder_methods.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/cart/cart_item_model.dart';

abstract class CartFirebaseDataSource {
  Future<CartItemModel> addToFavorites(CartItemModel cartItem);
  Future<CartItemModel> removeFromFavorites(CartItemModel cartItem);
  Future<List<CartItemModel>> syncCart(List<CartItemModel> cart);
}

class CartFirebaseDataSourceSourceImpl implements CartFirebaseDataSource {
  final FirebaseStorage storage;

  CartFirebaseDataSourceSourceImpl({required this.storage});

  @override
  Future<CartItemModel> addToFavorites(CartItemModel cartItem) async {
    FirestoreService firestoreService = FirestoreService();
    firestoreService.addProductToFavorites(cartItem);
    return cartItem;
  }

  @override
  Future<CartItemModel> removeFromFavorites(CartItemModel cartItem) async {
    FirestoreService firestoreService = FirestoreService();
    firestoreService.removeProductFromFavorites(cartItem);
    return cartItem;
  }

  @override
  Future<List<CartItemModel>> syncCart(
      List<CartItemModel> cart) async {

    for (final cartItem in cart) {
      final reference = storage.ref('users/${cartItem.userId}/favorites/${cartItem.product.id}');
      // reference.set(reference, jsonEncode(cartItem.toBodyJson()));
    }
    return cart;
  }
}
