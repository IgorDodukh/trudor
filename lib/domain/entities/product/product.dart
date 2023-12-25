import 'package:equatable/equatable.dart';
import 'package:spoto/core/constant/collections.dart';

import 'price_tag.dart';

class Product extends Equatable {
  final String id;
  final String? ownerId;
  final bool? isNew;
  final ProductStatus? status;
  final String name;
  final num price;
  final String description;
  final List<PriceTag> priceTags;

  // final List<Category> categories;
  final String category;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String contactName;
  final String? contactPhone;
  final String location;

  const Product({
    required this.id,
    required this.ownerId,
    required this.isNew,
    required this.status,
    required this.name,
    required this.price,
    required this.description,
    required this.priceTags,
    // required this.categories,
    required this.category,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.contactName,
    required this.contactPhone,
    required this.location,
  });

  @override
  List<Object?> get props => [id];
}
