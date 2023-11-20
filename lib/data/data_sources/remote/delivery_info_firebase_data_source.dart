
import 'package:eshop/core/util/firstore_folder_methods.dart';
import 'package:eshop/data/models/user/delivery_info_model.dart';
import 'package:firebase_storage/firebase_storage.dart';


abstract class DeliveryInfoFirebaseDataSource {
  Future<DeliveryInfoModel?> getDeliveryInfo(String userId);
  Future<DeliveryInfoModel> addDeliveryInfo(DeliveryInfoModel params);
  Future<DeliveryInfoModel> editDeliveryInfo(DeliveryInfoModel params);
}
class DeliveryInfoFirebaseDataSourceImpl implements DeliveryInfoFirebaseDataSource {
  final FirebaseStorage storage;

  DeliveryInfoFirebaseDataSourceImpl({required this.storage});

  @override
  Future<DeliveryInfoModel?> getDeliveryInfo(String userId) async {
    FirestoreService firestoreService = FirestoreService();
    return await firestoreService.getDeliveryInfo(userId);
  }

  @override
  Future<DeliveryInfoModel> addDeliveryInfo(DeliveryInfoModel params) async {
    FirestoreService firestoreService = FirestoreService();
    await firestoreService.addDeliveryInfo(params);
    return params;
  }

  @override
  Future<DeliveryInfoModel> editDeliveryInfo(DeliveryInfoModel params) async {
    FirestoreService firestoreService = FirestoreService();
    await firestoreService.updateDeliveryInfo(params);
    return params;
  }

}
