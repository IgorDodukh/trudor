import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String image;
  final List<dynamic> subcategory;

  const Category({
    required this.id,
    required this.name,
    required this.image,
    required this.subcategory,
  });

  @override
  List<Object?> get props => [id];
}
