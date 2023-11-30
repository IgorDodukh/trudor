import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:trudor/core/error/exceptions.dart';
import 'package:trudor/core/util/typesense_service.dart';
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
    TypesenseService typesenseService = TypesenseService();

    Future<void> createProduct(ProductModel product) async {
      try {
        final productData = product.toJson();
        await typesenseService.createCollection();
        await typesenseService.createDocument(productData);

        DocumentReference productRef = _firestore.collection('products').doc(productData['_id']);
        await productRef.set(productData);
      } catch (e) {
        EasyLoading.showError("Failed to add product: $e");
      }
    }

    Future<void> updateProduct(ProductModel product) async {
      try {
        final productData = product.toJson();
        await typesenseService.updateDocument(productData);
        DocumentReference productRef = _firestore.collection('products').doc(productData['_id']);
        await productRef.update(productData);
      } catch (e) {
        EasyLoading.showError("Failed to update product: $e");
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
        EasyLoading.showError("Failed to add product to favorites: $e");
      }
    }

    Future<void> addDeliveryInfo(DeliveryInfoModel deliveryInfo) async {
      try {
        final info = deliveryInfo.toJson();
        DocumentReference productRef = _firestore.collection('users').doc(deliveryInfo.userId);
        await productRef.set(info);
      } catch (e) {
        EasyLoading.showError("Failed to add address info: $e");
      }
    }

    Future<void> updateDeliveryInfo(DeliveryInfoModel deliveryInfo) async {
      try {
        final info = deliveryInfo.toJson();
        DocumentReference productRef = _firestore.collection('users').doc(deliveryInfo.userId);
        await productRef.update(info);
      } catch (e) {
        EasyLoading.showError("Failed to update address info: $e");
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
        EasyLoading.showError("Failed to get address info: $e");
      }
      return null;
    }

    Future<void> removeProductFromFavorites(FavoritesItemModel favoritesItem) async {
      try {
        DocumentReference productRef = _firestore.collection('favorites').doc(favoritesItem.userId);
        await productRef.update({favoritesItem.product.id: false});
      } catch (e) {
        EasyLoading.showError("Failed to remove product from favorites: $e");
      }
    }

    Future<void> updateProductName(String productId, String newName) async {
      try {
        await _firestore.collection('products').doc(productId).update({
          'name': newName,
        });
      } catch (e) {
        EasyLoading.showError("Failed to update product name: $e");
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
        EasyLoading.showError("Failed to get product details: $e");
      }
    }

    Future<ProductResponseModel> getProducts(FilterProductParams params) async {
      /// getting products from Typesense
      try {
        final foundProducts = typesenseService.searchProducts(params).then((value) => productResponseModelFromTypesense(value));
        return foundProducts;
      } catch (e) {
        EasyLoading.showError("Failed to get products: $e");
        throw ServerException();
      }
    }

    Future<ProductResponseModel> getProductsFromFirebase(FilterProductParams params) async {
      /// getting products from Firebase
      try {
        CollectionReference productsCollection = _firestore.collection('products');
        Query productsQuery = productsCollection;

        if (params.keyword != null && params.keyword!.isNotEmpty) {
          productsQuery = productsQuery.where('name', isGreaterThanOrEqualTo: params.keyword);
        }
        QuerySnapshot querySnapshot = await productsQuery.get();
        return productResponseModelFromFirestore(querySnapshot);
      } catch (e) {
        EasyLoading.showError("Failed to get products: $e");
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
        EasyLoading.showError("Failed to get categories: $e");
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
    }).catchError((error) => {EasyLoading.showError("Failed to remove image: $error")});
  }

}
