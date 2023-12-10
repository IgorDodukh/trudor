import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:spoto/core/constant/images.dart';
import 'package:spoto/core/util/firestore/firestore_images.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class ImageUploadForm extends StatefulWidget {
  // TODO: https://medium.flutterdevs.com/multiimage-picker-in-flutter-69bd9f6cedfb
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
  final int maxImages = 5;
  int _currentIndex = 0;
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
    final result = await picker.pickMultiImage(imageQuality: 50);
    return result.map((XFile file) => file).toList();
  }

  Future<List<String>> pickAndUploadImages() async {
    final images = await pickImages();
    setIsLoading();
    final imageUrls = await firestoreService.uploadImagesToFirebase(images);
    setState(() {
      this.imageUrls.addAll(imageUrls);
      widget.onImagesUploaded(this.imageUrls);
    });
    setIsLoading();
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
            if (imageUrls.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: imageUrls.length >= maxImages
                      ? null
                      : () async => {
                            await pickAndUploadImages(),
                          },
                  child: const Text('Add more',
                      style: TextStyle(decoration: TextDecoration.underline)),
                ),
              ),
          ],
        ),
        if (imageUrls.isNotEmpty) ...[
          SizedBox(
            height: 200,
            child: CarouselSlider(
              options: CarouselOptions(
                height: double.infinity,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                aspectRatio: 16 / 9,
                viewportFraction: 1,
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
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: isLoading
                                ? const CircularProgressIndicator.adaptive()
                                : Image.network(imageUrl, fit: BoxFit.cover)),
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
            height: 250,
            child: TextButton(
              onPressed: () async => {
                await pickAndUploadImages(),
              },
              child: isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : Container(
                      width: 300.0,
                      height: 250.0,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(kAddPhoto), fit: BoxFit.cover)),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 160.0),
                        child: Center(
                            child: Text("Add pictures",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold))),
                      ),
                    ),
            ),
          ),
        ],
        const SizedBox(height: 12.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: StepProgressIndicator(
            totalSteps: maxImages,
            currentStep: imageUrls.length,
            selectedColor: Colors.black87,
            unselectedColor: Colors.grey,
          ),
        ),
        const SizedBox(height: 2.0),
        FAProgressBar(
          size: 20,
          maxValue: maxImages.toDouble(),
          currentValue: imageUrls.length.toDouble(),
          displayText: '/$maxImages',
          progressColor: Colors.white,
          displayTextStyle:
              const TextStyle(color: Colors.black87, fontSize: 14),
        ),
      ],
    );
  }
}
