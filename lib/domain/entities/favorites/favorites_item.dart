import 'package:equatable/equatable.dart';

import '../product/price_tag.dart';
import '../product/product.dart';

class ListViewItem extends Equatable {
  final String? id;
  final Product product;
  final PriceTag priceTag;
  final String? addedAt;
  final String? userId;

  const ListViewItem({this.id, required this.product, required this.priceTag, this.addedAt, this.userId});

  @override
  List<Object?> get props => [id];
}
