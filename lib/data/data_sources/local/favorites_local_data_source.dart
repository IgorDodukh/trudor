import 'package:trudor/core/error/failures.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/favorites/favorites_item_model.dart';

abstract class FavoritesLocalDataSource {
  Future<List<FavoritesItemModel>> getFavorites();

  Future<void> saveFavorites(List<FavoritesItemModel> favorites);

  Future<void> saveFavoritesItem(FavoritesItemModel favoritesItem);

  Future<bool> removeFavoritesItem(FavoritesItemModel favoritesItem);

  Future<bool> clearFavorites();
}

const cachedFavorites = 'CACHED_FAVORITES';

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final SharedPreferences sharedPreferences;

  FavoritesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveFavorites(List<FavoritesItemModel> favorites) {
    return sharedPreferences.setString(
      cachedFavorites,
      favoritesItemModelToJson(favorites),
    );
  }

  @override
  Future<void> saveFavoritesItem(FavoritesItemModel favoritesItem) {
    final jsonString = sharedPreferences.getString(cachedFavorites);
    final List<FavoritesItemModel> favorites = [];
    if (jsonString != null) {
      favorites.addAll(favoritesItemModelListFromLocalJson(jsonString));
    }
    if (!favorites.any((element) =>
        element.product.id == favoritesItem.product.id &&
        element.priceTag.id == favoritesItem.priceTag.id)) {
      favorites.add(favoritesItem);
    }
    return sharedPreferences.setString(
      cachedFavorites,
      favoritesItemModelToJson(favorites),
    );
  }

  @override
  Future<List<FavoritesItemModel>> getFavorites() {
    final jsonString = sharedPreferences.getString(cachedFavorites);
    if (jsonString != null) {
      return Future.value(favoritesItemModelListFromLocalJson(jsonString));
    } else {
      return Future.value([]);
      // leave this throw for future error handling
      // throw CacheFailure();
    }
  }

  @override
  Future<bool> clearFavorites() async {
    return sharedPreferences.remove(cachedFavorites);
  }

  @override
  Future<bool> removeFavoritesItem(FavoritesItemModel favoritesItem) async {
    final jsonString = sharedPreferences.getString(cachedFavorites);
    if (jsonString != null) {
      final List<FavoritesItemModel> favorites =
          favoritesItemModelListFromLocalJson(jsonString);

      // Remove the specified favorites item from the list
      favorites.removeWhere((item) =>
          item.product.id == favoritesItem.product.id &&
          item.priceTag.id == favoritesItem.priceTag.id);

      return await sharedPreferences.setString(cachedFavorites, favoritesItemModelToJson(favorites));
    } else {
      // Handle the case where the favorites is not found in local storage
      throw CacheFailure();
    }
  }
}
