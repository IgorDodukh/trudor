import 'package:spoto/domain/entities/favorites/favorites_item.dart';
import 'package:spoto/domain/entities/product/product.dart';

class ProductMapping {

  static ListViewItem productToListViewItem(Product productItem) {
    return ListViewItem(
        product: productItem,
        priceTag: productItem.priceTags.first
    );
  }
}