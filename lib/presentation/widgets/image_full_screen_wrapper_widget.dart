import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:spoto/core/constant/strings.dart';

class DetailScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const DetailScreen(this.imageUrls, this.currentIndex, this.onIndexChanged,
      {super.key});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.message)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
        ],
      ),
      body: GestureDetector(
        child: Stack(children: [
          CarouselSlider(
            options: CarouselOptions(
              height: double.infinity,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              aspectRatio: 16 / 9,
              viewportFraction: 1,
              initialPage: widget.currentIndex,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                  widget.onIndexChanged(index);
                });
              },
            ),
            items: widget.imageUrls.map((image) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    child: Hero(
                      tag: "imageTag",
                      child: ExtendedImage.network(
                        image.isEmpty ? noImagePlaceholder : image,
                        fit: BoxFit.fitWidth,
                        cache: true,
                        mode: ExtendedImageMode.gesture,
                        initGestureConfigHandler: (state) {
                          return GestureConfig(
                            minScale: 1,
                            animationMinScale: 0.7,
                            maxScale: 3.0,
                            animationMaxScale: 3.5,
                            speed: 1.0,
                            inertialSpeed: 500.0,
                            initialScale: 1.0,
                            inPageView: false,
                            initialAlignment: InitialAlignment.center,
                          );
                        },
                      ),
                    ),
                    onVerticalDragUpdate: (details) {
                      if (details.delta.dy > 0) {
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              );
            }).toList(),
          ),
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.9),
            child: Align(
              alignment: Alignment.center,
              child: AnimatedSmoothIndicator(
                activeIndex: _currentIndex,
                count: widget.imageUrls.length,
                effect: const ScrollingDotsEffect(
                    dotColor: Colors.grey,
                    maxVisibleDots: 7,
                    activeDotColor: Colors.blue,
                    dotHeight: 6,
                    dotWidth: 6,
                    activeDotScale: 1.1,
                    spacing: 6),
              ),
            ),
          ),
        ]),
        // onVerticalDragUpdate: (details) {
        //   if (details.delta.dy > 0) {
        //     Navigator.pop(context);
        //   }
        // },
      ),
    );
  }
}

// TODO: try https://github.com/Tkko/Flutter_dismissible_page/tree/master/lib/src
class DoubleTappableInteractiveViewer extends StatefulWidget {
  final double scale;
  final Duration scaleDuration;
  final Curve curve;
  final Widget child;

  const DoubleTappableInteractiveViewer({
    super.key,
    this.scale = 2,
    this.curve = Curves.fastLinearToSlowEaseIn,
    required this.scaleDuration,
    required this.child,
  });

  @override
  State<DoubleTappableInteractiveViewer> createState() =>
      _DoubleTappableInteractiveViewerState();
}

class _DoubleTappableInteractiveViewerState
    extends State<DoubleTappableInteractiveViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Animation<Matrix4>? _zoomAnimation;
  late TransformationController _transformationController;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.scaleDuration,
    )..addListener(() {
        _transformationController.value = _zoomAnimation!.value;
      });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    final newValue = _transformationController.value.isIdentity()
        ? _applyZoom()
        : _revertZoom();

    _zoomAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: newValue,
    ).animate(CurveTween(curve: widget.curve).animate(_animationController));
    _animationController.forward(from: 0);
  }

  Matrix4 _applyZoom() {
    final tapPosition = _doubleTapDetails!.localPosition;
    final translationCorrection = widget.scale - 1;
    final zoomed = Matrix4.identity()
      ..translate(
        -tapPosition.dx * translationCorrection,
        -tapPosition.dy * translationCorrection,
      )
      ..scale(widget.scale);
    return zoomed;
  }

  Matrix4 _revertZoom() => Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        child: widget.child,
      ),
    );
  }
}
