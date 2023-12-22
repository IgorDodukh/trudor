import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spoto/core/util/firestore/firestore_images.dart';

class ImageUploadForm extends StatefulWidget {
  final ValueChanged<List<String>> onImagesUploaded;
  final List<String>? existingImages;

  const ImageUploadForm({
    super.key,
    this.existingImages,
    required this.onImagesUploaded,
  });

  @override
  State<ImageUploadForm> createState() => _ImageUploadFormState();
}

class _ImageUploadFormState extends State<ImageUploadForm> {
  List<String> imageUrls = [];
  final int maxImages = 9;
  bool photosLimitReached = false;
  bool isLoading = false;
  FirestoreImages firestoreService = FirestoreImages();

  @override
  void initState() {
    setState(() {
      imageUrls = widget.existingImages ?? [];
    });
    super.initState();
  }

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  Future<List<XFile>> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final result = await picker.pickMultiImage(imageQuality: 30);
    return result.map((XFile file) => file).toList();
  }

  Future<XFile?> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '${file.path}_compressed.jpg',
      quality: 60,
    );
    return result;
  }

  Future<List<String>> pickAndUploadImages() async {
    final images = await pickImages();
    setIsLoading();
    for (var image in images) {
      print("IMAGE: ${image.name}");
      final resultFile =
          await testCompressAndGetFile(File(image.path), image.path);
      final imageUrls =
          await firestoreService.uploadImagesToFirebase([resultFile!]);
      this.imageUrls.addAll(imageUrls);
      if (this.imageUrls.length >= maxImages) {
        break;
      }
    }
    setState(() {
      widget.onImagesUploaded(imageUrls);
    });
    setIsLoading();
    return imageUrls;
  }

  Widget removeImageButton(BuildContext context, String imageUrl) {
    return Positioned(
      right: 8,
      top: 8,
      child: InkWell(
        child: const Icon(
          Icons.remove_circle,
          size: 24,
          color: Colors.redAccent,
        ),
        onTap: () async {
          await firestoreService.removeImageFromFirebase(imageUrl);
          setState(() {
            int pickedImageIndex = imageUrls.indexOf(imageUrl);
            imageUrls.removeAt(pickedImageIndex);
            widget.onImagesUploaded(imageUrls);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        imageUrls.isEmpty
            ? Center(
                child: Column(children: [
                const SizedBox(
                  height: 30,
                ),
                const Icon(
                  CupertinoIcons.photo_on_rectangle,
                  size: 200,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextButton(
                  onPressed: imageUrls.length >= maxImages
                      ? null
                      : () async => {
                            EasyLoading.show(
                                status: 'Processing images.\nPlease wait.',
                                dismissOnTap: false),
                            await pickAndUploadImages(),
                            EasyLoading.dismiss(),
                          },
                  child: const Text('Add pictures',
                      style: TextStyle(
                          decoration: TextDecoration.underline, fontSize: 20)),
                ),
              ]))
            : Container(
                height: 345,
                // decoration: const BoxDecoration(
                //   color: Colors.black12,
                //   borderRadius: BorderRadius.all(Radius.circular(12)),
                // ),
                child: GridView.builder(
                  itemCount: imageUrls.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    if (imageUrls.length > index) {
                      return Stack(children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Card(
                            color: Colors.white,
                            surfaceTintColor: Colors.white,
                            elevation: 2,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: CachedNetworkImage(
                                imageUrl: imageUrls[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        removeImageButton(context, imageUrls[index]),
                      ]);
                    }
                    return imageUrls.length < maxImages
                        ? SizedBox(
                            child: TextButton(
                              onPressed: imageUrls.length >= maxImages
                                  ? null
                                  : () async => {
                                        EasyLoading.show(
                                            status:
                                                'Processing images.\nPlease wait.',
                                            dismissOnTap: false),
                                        await pickAndUploadImages(),
                                        EasyLoading.dismiss(),
                                      },
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 40,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Add more',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : null;
                  },
                ),
              ),
      ],
    );
  }
}
