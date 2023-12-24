import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spoto/core/util/firestore/firestore_images.dart';

class ImageUploader {
  static FirestoreImages firestoreService = FirestoreImages();

  static Future<XFile?> testCompressAndGetFile(
      File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '${file.path}_compressed.jpg',
      quality: 60,
    );
    return result;
  }

  static Future<XFile?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    return result;
  }

  static Future<String> pickAndUploadImage() async {
    final image = await pickImage();
    final resultFile =
        await testCompressAndGetFile(File(image!.path), image.path);
    final imageUrls = await firestoreService.uploadImagesToFirebase([resultFile!]);
    return imageUrls.first;
  }

  static Future<List<XFile>> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final result = await picker.pickMultiImage();
    return result.map((XFile file) => file).toList();
  }

  static Future<List<String>> pickAndUploadImages(int maxImages) async {
    final imageUrls = <String>[];
    final images = await pickImages();
    for (var image in images) {
      print("IMAGE: ${image.name}");
      final resultFile = await testCompressAndGetFile(File(image.path), image.path);
      final uploadResult = await firestoreService.uploadImagesToFirebase([resultFile!]);
      imageUrls.addAll(uploadResult);
      if (imageUrls.length >= maxImages) {
        break;
      }
    }
    // setState(() {
    //   widget.onImagesUploaded(imageUrls);
    // });
    return imageUrls;
  }
}
