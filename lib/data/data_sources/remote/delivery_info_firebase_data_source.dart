import 'package:firebase_storage/firebase_storage.dart';
import 'package:spoto/core/util/firestore/firestore_delivery_info.dart';
import 'package:spoto/data/models/user/delivery_info_model.dart';

abstract class DeliveryInfoFirebaseDataSource {
  Future<DeliveryInfoModel?> getDeliveryInfo(String userId);

  Future<DeliveryInfoModel> addDeliveryInfo(DeliveryInfoModel params);

  Future<DeliveryInfoModel> editDeliveryInfo(DeliveryInfoModel params);
}

class DeliveryInfoFirebaseDataSourceImpl
    implements DeliveryInfoFirebaseDataSource {
  final FirebaseStorage storage;

  DeliveryInfoFirebaseDataSourceImpl({required this.storage});

  @override
  Future<DeliveryInfoModel?> getDeliveryInfo(String userId) async {
    FirestoreDeliveryInfo firestoreDeliveryInfo = FirestoreDeliveryInfo();
    return await firestoreDeliveryInfo.getDeliveryInfo(userId);
  }

  @override
  Future<DeliveryInfoModel> addDeliveryInfo(DeliveryInfoModel params) async {
    FirestoreDeliveryInfo firestoreDeliveryInfo = FirestoreDeliveryInfo();
    await firestoreDeliveryInfo.addDeliveryInfo(params);
    return params;
  }

  @override
  Future<DeliveryInfoModel> editDeliveryInfo(DeliveryInfoModel params) async {
    FirestoreDeliveryInfo firestoreDeliveryInfo = FirestoreDeliveryInfo();
    await firestoreDeliveryInfo.updateDeliveryInfo(params);
    return params;
  }
}
