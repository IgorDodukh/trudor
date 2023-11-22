import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trudor/core/error/exceptions.dart';
import 'package:trudor/data/models/favorites/favorites_item_model.dart';
import 'package:trudor/data/models/category/category_model.dart';
import 'package:trudor/data/models/product/product_model.dart';
import 'package:trudor/data/models/product/product_response_model.dart';
import 'package:trudor/data/models/user/delivery_info_model.dart';
import 'package:trudor/domain/usecases/product/get_product_usecase.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirestoreService {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    Future<void> createProduct(ProductModel product) async {
      try {
        final productData = product.toJson();
        DocumentReference productRef = _firestore.collection('products').doc(productData['_id']);
        await productRef.set(productData);
      } catch (e) {
        print('Error adding product to Firestore: $e');
      }
    }

    Future<void> updateProduct(ProductModel product) async {
      try {
        final productData = product.toJson();
        DocumentReference productRef = _firestore.collection('products').doc(productData['_id']);
        await productRef.update(productData);
      } catch (e) {
        print('Error updating product in Firestore: $e');
      }
    }

    Future<void> addProductToFavorites(FavoritesItemModel favoritesItem) async {
      try {
        DocumentReference productRef = _firestore.collection('favorites').doc(favoritesItem.userId);
        final snapshot = await productRef.get();
        if (!snapshot.exists) {
          productRef.set({favoritesItem.product.id: true});
        } else {
          await productRef.update({favoritesItem.product.id: true});
        }
      } catch (e) {
        print('Error adding product to Firestore Favorites: $e');
      }
    }

    Future<void> addDeliveryInfo(DeliveryInfoModel deliveryInfo) async {
      try {
        final info = deliveryInfo.toJson();
        DocumentReference productRef = _firestore.collection('users').doc(deliveryInfo.userId);
        await productRef.set(info);
      } catch (e) {
        print('Error adding Delivery info to Firestore: $e');
      }
    }

    Future<void> updateDeliveryInfo(DeliveryInfoModel deliveryInfo) async {
      try {
        final info = deliveryInfo.toJson();
        DocumentReference productRef = _firestore.collection('users').doc(deliveryInfo.userId);
        await productRef.update(info);
      } catch (e) {
        print('Error updating Delivery info in Firestore: $e');
      }
    }

    Future<DeliveryInfoModel?> getDeliveryInfo(String userId) async {
      try {
        DocumentReference deliveryInfoRef = _firestore.collection('users').doc(userId);
        final deliveryInfo = await deliveryInfoRef.get();
        if (deliveryInfo.exists) {
          final data = deliveryInfo.data() as Map<String, dynamic>;
          final info = DeliveryInfoModel.fromJson(data);
          return info;
        } else {
        }
      } catch (e) {
        print('Error adding Delivery info to Firestore: $e');
      }
      return null;
    }

    Future<void> removeProductFromFavorites(FavoritesItemModel favoritesItem) async {
      try {
        DocumentReference productRef = _firestore.collection('favorites').doc(favoritesItem.userId);
        await productRef.update({favoritesItem.product.id: false});
      } catch (e) {
        print('Error removing product from Firestore Favorites: $e');
      }
    }

    Future<void> updateProductName(String productId, String newName) async {
      try {
        await _firestore.collection('products').doc(productId).update({
          'name': newName,
        });
      } catch (e) {
        print('Error updating product name: $e');
      }
    }

    Future<void> getProduct(String productId) async {
      try {
        final doc = await _firestore.collection('products').doc(productId).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          print('Product: ${data['name']}, ${data['description']}');
        } else {
          print('Product not found');
        }
      } catch (e) {
        print('Error getting product: $e');
      }
    }

    Future<ProductResponseModel> getProducts(FilterProductParams params) async {
      try {
        CollectionReference productsCollection = _firestore.collection('products');
        Query productsQuery = productsCollection;

        if (params.keyword != null && params.keyword!.isNotEmpty) {
          productsQuery = productsQuery.where('name', arrayContains: params.keyword);
        }

        if (params.categories.isNotEmpty) {
          productsQuery = productsQuery.where('categories', arrayContainsAny: params.categories.map((e) => e.id).toList());
        }

        if (params.pageSize != null && params.pageSize! > 0) {
          productsQuery = productsQuery.limit(params.pageSize!);
        }
        QuerySnapshot querySnapshot = await productsQuery.get();
        return productResponseModelFromFirestore(querySnapshot);
      } catch (e) {
        print('Error getting products: $e');
        throw ServerException();
      }
    }

    Future<List<CategoryModel>?> getCategories() async {
      try {
        final querySnapshot = await _firestore.collection('categories').get();
        final categories = querySnapshot.docs
            .map((doc) => doc.data())
            .toList();
        return List<CategoryModel>.from(categories.map((x) => CategoryModel.fromJson(x)));
      } catch (e) {
        print('Error getting products: $e');
      }
      return null;
    }

  Future<List<String>> uploadImagesToFirebase(List<XFile> images) async {
    final List<String> imageUrls = [];
    for (final image in images) {
      final Reference reference = FirebaseStorage.instance.ref().child('images/${image.name}');
      final UploadTask uploadTask = reference.putFile(File(image.path));
      final TaskSnapshot taskSnapshot =
      await uploadTask.whenComplete(() => null);
      final String imageUrl = await taskSnapshot.ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }
    return imageUrls;
  }

  Future<void> removeImageFromFirebase(String imageUrl) async {
    final Reference fileRef = FirebaseStorage.instance.refFromURL(imageUrl);
    fileRef.delete().then((value) => {
      print("Image was deleted"),
    }).catchError((error) => {print("Error happened: $error")});
  }

}
