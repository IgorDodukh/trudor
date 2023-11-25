import 'package:carousel_slider/carousel_slider.dart';
import 'package:trudor/core/util/firstore_folder_methods.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageUploadForm extends StatefulWidget {
  final ValueChanged<List<String>> onImagesUploaded;

  const ImageUploadForm({super.key, required this.onImagesUploaded});

  @override
  State<ImageUploadForm> createState() => _ImageUploadFormState();
}

class _ImageUploadFormState extends State<ImageUploadForm> {
  List<String> imageUrls = [];
  final int maxImages = 5;
  int _currentIndex = 0;
  bool photosLimitReached = false;
  FirestoreService firestoreService = FirestoreService();

  Future<List<XFile>> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final result = await picker.pickMultiImage();
    return result.map((XFile file) => file).toList();
  }

  Future<List<String>> pickAndUploadImages() async {
    final images = await pickImages();
    final imageUrls = await firestoreService.uploadImagesToFirebase(images);
    setState(() {
      this.imageUrls.addAll(imageUrls);
      widget.onImagesUploaded(this.imageUrls);
    });
    return imageUrls;
  }

  void showAlertDialog(BuildContext context, String imageUrl) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget removeButton = TextButton(
      child: const Text("Remove"),
      onPressed: () async {
        await firestoreService.removeImageFromFirebase(imageUrl);

        setState(() {
          int pickedImageIndex = imageUrls.indexOf(imageUrl);
          imageUrls.removeAt(pickedImageIndex);
          widget.onImagesUploaded(imageUrls);
        });
        Navigator.pop(context);
      },
    );
    Widget setMainImageButton = TextButton(
      child: const Text("Make primary"),
      onPressed: () {
        setState(() {
          // imageUrls.removeAt(imageUrl);
        });
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      surfaceTintColor: Colors.grey,
      title: const Text("Image actions"),
      actions: [
        setMainImageButton,
        removeButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: add validation if upload more than max images at once
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            (imageUrls.length < maxImages)
                ? Text(
                    "${maxImages - imageUrls.length} more photo(s) can be added")
                : const Text(
                    "Upload limit is reached",
                    style: TextStyle(color: Colors.deepOrangeAccent),
                  ),
            const SizedBox(width: 20.0),
            if (imageUrls.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: imageUrls.length >= maxImages
                      ? null
                      : () async => {
                            await pickAndUploadImages(),
                          },
                  child: const Text('Add more'),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20.0),
        if (imageUrls.isNotEmpty) ...[
          SizedBox(
            height: 150,
            child: CarouselSlider(
              options: CarouselOptions(
                height: 300,
                aspectRatio: 16 / 9,
                viewportFraction: 0.7,
                enableInfiniteScroll: false,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: imageUrls.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Image.network(imageUrl)),
                        onTap: () {
                          showAlertDialog(context, imageUrl);
                        });
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.center,
              child: AnimatedSmoothIndicator(
                activeIndex: _currentIndex,
                count: imageUrls.length,
                effect: ScrollingDotsEffect(
                    dotColor: Colors.grey.shade300,
                    maxVisibleDots: 7,
                    activeDotColor: Colors.grey,
                    dotHeight: 6,
                    dotWidth: 6,
                    activeDotScale: 1.1,
                    spacing: 6),
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            height: MediaQuery.sizeOf(context).width / 3,
            child: TextButton(
              onPressed: () async => {
                await pickAndUploadImages(),
              },
              child: const Text('Add photos'),
            ),
          ),
        ],
      ],
    );
  }
}
