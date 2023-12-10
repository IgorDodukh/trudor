import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spoto/core/util/typesense/typesense_service.dart';
import 'package:spoto/data/models/user/delivery_info_model.dart';

class FirestoreDeliveryInfo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TypesenseService typesenseService = TypesenseService();

  Future<void> addDeliveryInfo(DeliveryInfoModel deliveryInfo) async {
    try {
      final info = deliveryInfo.toJson();
      DocumentReference productRef =
      _firestore.collection('users').doc(deliveryInfo.userId);
      await productRef.set(info);
    } catch (e) {
      EasyLoading.showError("Failed to add address info: $e");
    }
  }

  Future<void> updateDeliveryInfo(DeliveryInfoModel deliveryInfo) async {
    try {
      final info = deliveryInfo.toJson();
      DocumentReference productRef =
      _firestore.collection('users').doc(deliveryInfo.userId);
      await productRef.update(info);
    } catch (e) {
      EasyLoading.showError("Failed to update address info: $e");
    }
  }

  Future<DeliveryInfoModel?> getDeliveryInfo(String userId) async {
    try {
      DocumentReference deliveryInfoRef =
      _firestore.collection('users').doc(userId);
      final deliveryInfo = await deliveryInfoRef.get();
      if (deliveryInfo.exists) {
        final data = deliveryInfo.data() as Map<String, dynamic>;
        final info = DeliveryInfoModel.fromJson(data);
        return info;
      } else {}
    } catch (e) {
      EasyLoading.showError("Failed to get address info: $e");
    }
    return null;
  }

}