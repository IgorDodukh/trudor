import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';

class FirestoreImages {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<List<String>> uploadImagesToFirebase(List<XFile> images) async {
    final List<String> imageUrls = [];
    for (final image in images) {
      final Reference reference =
          _firebaseStorage.ref().child('images/${image.name}');
      final UploadTask uploadTask = reference.putFile(File(image.path));
      final TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);
      final String imageUrl = await taskSnapshot.ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }
    return imageUrls;
  }

  Future<void> removeImageFromFirebase(String imageUrl) async {
    final Reference fileRef = _firebaseStorage.refFromURL(imageUrl);
    fileRef
        .delete()
        .then((value) => {
              print("Image was deleted"),
            })
        .catchError((error) =>
            {EasyLoading.showError("Failed to remove image: $error")});
  }
}
