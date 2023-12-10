import 'package:flutter/material.dart';
import 'package:spoto/core/util/firestore/firestore_categories.dart';
import 'package:spoto/data/models/category/category_model.dart';
import 'package:spoto/domain/entities/category/category.dart';

class CategoriesDropdownMenu extends StatefulWidget {
  final ValueChanged<CategoryModel> onCategorySelected;
  final Category? existingCategory;

  const CategoriesDropdownMenu(
      {Key? key, this.existingCategory, required this.onCategorySelected})
      : super(key: key);

  @override
  State<CategoriesDropdownMenu> createState() => _CategoriesDropdownMenuState();
}

class _CategoriesDropdownMenuState extends State<CategoriesDropdownMenu> {
  final TextEditingController controller = TextEditingController();
  FirestoreCategories firestoreService = FirestoreCategories();
  String? _selectedCategory;
  List<CategoryModel>? _categoriesList;
  late final Future<List<CategoryModel>> getCategoriesFuture;

  @override
  void initState() {
    _selectedCategory = widget.existingCategory?.name;
    getCategoriesFuture = getAllCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryModel>>(
      future: getCategoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 55,
            child: Center(
              child: CircularProgressIndicator.adaptive(), // Loading indicator
            ),
          );
        } else if (snapshot.hasError) {
          return const SizedBox(
            height: 55,
            child: Center(
              child: Text('Error loading categories'),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 55,
            child: Center(
              child: Text('No categories available'),
            ),
          );
        } else {
          _categoriesList = snapshot.data!;
          return SizedBox(
            height: 55,
            child: DropdownButtonFormField(
              value: _selectedCategory,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
              hint: const Text('Select a category'),
              onChanged: (String? newValue) {
                CategoryModel selectedCategory = _categoriesList!.first;
                for (CategoryModel category in _categoriesList!) {
                  if (category.name == newValue) {
                    selectedCategory = category;
                  }
                }
                setState(() {
                  _selectedCategory = newValue;
                  widget.onCategorySelected(selectedCategory);
                });
              },
              validator: (String? val) {
                if (val == null || val.isEmpty) {
                  return 'Category can\'t be empty';
                }
                return null;
              },
              items: _categoriesList!
                  .map<DropdownMenuItem<String>>((CategoryModel categoryModel) {
                return DropdownMenuItem<String>(
                  value: categoryModel.name,
                  child: Text(
                    categoryModel.name,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final modelsList = await firestoreService.getCategories();
      return modelsList?.toList() ?? [];
    } catch (e) {
      // Handle errors
      return [];
    }
  }
}
