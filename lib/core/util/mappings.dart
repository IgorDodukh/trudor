import 'package:trudor/domain/entities/favorites/favorites_item.dart';
import 'package:trudor/domain/entities/product/product.dart';

class ProductMapping {

  static ListViewItem productToListViewItem(Product productItem) {
    return ListViewItem(
        product: productItem,
        priceTag: productItem.priceTags.first
    );
  }
}