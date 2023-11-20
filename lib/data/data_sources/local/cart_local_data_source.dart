import 'package:eshop/core/error/failures.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/cart/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCart();

  Future<void> saveCart(List<CartItemModel> cart);

  Future<void> saveCartItem(CartItemModel cartItem);

  Future<bool> removeCartItem(CartItemModel cartItem);

  Future<bool> clearCart();
}

const cachedCart = 'CACHED_CART';

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;

  CartLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveCart(List<CartItemModel> cart) {
    return sharedPreferences.setString(
      cachedCart,
      cartItemModelToJson(cart),
    );
  }

  @override
  Future<void> saveCartItem(CartItemModel cartItem) {
    final jsonString = sharedPreferences.getString(cachedCart);
    final List<CartItemModel> cart = [];
    if (jsonString != null) {
      cart.addAll(cartItemModelListFromLocalJson(jsonString));
    }
    if (!cart.any((element) =>
        element.product.id == cartItem.product.id &&
        element.priceTag.id == cartItem.priceTag.id)) {
      cart.add(cartItem);
    }
    return sharedPreferences.setString(
      cachedCart,
      cartItemModelToJson(cart),
    );
  }

  @override
  Future<List<CartItemModel>> getCart() {
    final jsonString = sharedPreferences.getString(cachedCart);
    if (jsonString != null) {
      return Future.value(cartItemModelListFromLocalJson(jsonString));
    } else {
      throw CacheFailure();
    }
  }

  @override
  Future<bool> clearCart() async {
    return sharedPreferences.remove(cachedCart);
  }

  @override
  Future<bool> removeCartItem(CartItemModel cartItem) async {
    final jsonString = sharedPreferences.getString(cachedCart);
    if (jsonString != null) {
      final List<CartItemModel> cart =
          cartItemModelListFromLocalJson(jsonString);

      // Remove the specified cart item from the list
      cart.removeWhere((item) =>
          item.product.id == cartItem.product.id &&
          item.priceTag.id == cartItem.priceTag.id);

      return await sharedPreferences.setString(cachedCart, cartItemModelToJson(cart));
    } else {
      // Handle the case where the cart is not found in local storage
      throw CacheFailure();
    }
  }
}
