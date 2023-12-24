import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spoto/data/models/user/user_model.dart';

class FirestoreUsers {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUserInfo(UserModel userModel) async {
    try {
      final user = userModel.toJson();
      final snapshot = await _firestore.collection('users').get();
      final bool isUserExists =
          snapshot.docs.map((element) => element.id == userModel.id).first;
      if (!isUserExists) {
        DocumentReference productRef =
            _firestore.collection('users').doc(userModel.id);
        await productRef.set(user);
      }
    } catch (e) {
      print("Failed to add address info: $e");
    }
  }

  Future<void> updateUserInfo(UserModel userModel) async {
    try {
      final info = userModel.toJson();
      DocumentReference productRef =
          _firestore.collection('users').doc(userModel.id);
      await productRef.update(info);
    } catch (e) {
      print("Failed to update address info: $e");
    }
  }

  Future<UserModel?> getUserInfo(String userId) async {
    try {
      DocumentReference userInfoRef =
          _firestore.collection('users').doc(userId);
      final userInfo = await userInfoRef.get();
      if (userInfo.exists) {
        final data = userInfo.data() as Map<String, dynamic>;
        final info = UserModel.fromJson(data);
        return info;
      } else {}
    } catch (e) {
      print("Failed to get user info: $e");
    }
    return null;
  }
}
