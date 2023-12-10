import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spoto/data/models/category/category_model.dart';

class FirestoreCategories {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CategoryModel>?> getCategories() async {
    try {
      final querySnapshot = await _firestore.collection('categories').get();
      final categories = querySnapshot.docs.map((doc) => doc.data()).toList();
      return List<CategoryModel>.from(
          categories.map((x) => CategoryModel.fromJson(x)));
    } catch (e) {
      EasyLoading.showError("Failed to get categories: $e");
    }
    return null;
  }

}