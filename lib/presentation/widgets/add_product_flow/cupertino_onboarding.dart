import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/presentation/widgets/buttons/back_button.dart';
import 'package:spoto/presentation/widgets/buttons/next_button.dart';

final CupertinoDynamicColor _kBackgroundColor =
    CupertinoDynamicColor.withBrightness(
  color: CupertinoColors.white,
  darkColor: CupertinoColors.systemGrey6.darkColor,
);

final CupertinoDynamicColor _kActiveDotColor =
    CupertinoDynamicColor.withBrightness(
  color: CupertinoColors.systemGrey2.darkColor,
  darkColor: CupertinoColors.systemGrey2.color,
);
final CupertinoDynamicColor _kInactiveDotColor =
    CupertinoDynamicColor.withBrightness(
  color: CupertinoColors.systemGrey2.color,
  darkColor: CupertinoColors.systemGrey2.darkColor,
);

const Size _kDotSize = Size(8, 8);

const EdgeInsets _kBottomButtonPadding = EdgeInsets.only(
  left: 22,
  right: 22,
  bottom: 12,
);
const EdgeInsets _kTopBackButtonPadding = EdgeInsets.only(
  left: 12,
  bottom: 10,
);

class CupertinoOnboarding extends StatefulWidget {
  CupertinoOnboarding({
    required this.pages,
    this.backgroundColor,
    this.bottomButtonChild = const Text(continueTitle),
    this.bottomBackButtonChild =
        const Text(goBackTitle, style: TextStyle(color: CupertinoColors.black)),
    this.bottomButtonColor,
    this.bottomButtonBackColor,
    this.bottomButtonBorderRadius,
    this.bottomButtonPadding = _kBottomButtonPadding,
    this.widgetAboveBottomButton,
    this.pageTransitionAnimationDuration = const Duration(milliseconds: 500),
    this.pageTransitionAnimationCurve = Curves.fastEaseInToSlowEaseOut,
    this.scrollPhysics = const BouncingScrollPhysics(),
    this.onPressed,
    this.onPressedOnLastPage,
    this.onPressedOnFirstPage,
    super.key,
    this.secondFormKey,
    this.thirdFormKey,
    this.editPageKey,
  }) : assert(
          pages.isNotEmpty,
          'Number of pages must be greater than 0',
        );

  /// List of Widgets that will be displayed as pages.
  ///
  /// Preferably, list of `CupertinoOnboardingPage`
  /// or `WhatsNewPage` widgets.
  final List<Widget> pages;

  /// Background color of the onboarding screen.
  ///
  /// Defaults to the iOS style.
  final Color? backgroundColor;

  /// Child used in the bottom button.
  ///
  /// Default to the Text('Continue') widget.
  final Widget bottomButtonChild;

  final Widget bottomBackButtonChild;

  /// Background color of the bottom button.
  ///
  /// Default color is derived
  /// from the [CupertinoTheme]'s primaryColor.
  final Color? bottomButtonColor;

  final Color? bottomButtonBackColor;

  /// Border radius of the next button.
  ///
  /// Can't match native iOS look, because as of 3.0.3 Flutter
  /// still uses rounded rectangle shape for [CupertinoButton]
  /// instead of squircle paths.
  /// https://github.com/flutter/flutter/issues/13914
  final BorderRadius? bottomButtonBorderRadius;

  /// Padding of the bottom button.
  final EdgeInsets bottomButtonPadding;

  /// Widget that is placed above the bottom button.
  ///
  /// E.g. a [CupertinoButton] that links to the privacy policy page.
  final Widget? widgetAboveBottomButton;

  /// Duration that is used to animate the transition between pages.
  ///
  /// Defaults to `const Duration(milliseconds: 500)`.
  final Duration pageTransitionAnimationDuration;

  /// Animation curve that is used to animate the transition between pages.
  ///
  /// Defaults to [Curves.fastEaseInToSlowEaseOut].
  final Curve pageTransitionAnimationCurve;

  /// The physics to use for horizontal
  /// scrolling between the pages.
  ///
  /// Defaults to [BouncingScrollPhysics].
  final ScrollPhysics scrollPhysics;

  /// Invoked when the user taps on the bottom button.
  /// Usable only if [pages] length is greater than 1.
  ///
  /// By default, it will navigate to the next page.
  final VoidCallback? onPressed;

  /// Invoked when the user taps on the bottom button on the last page.
  /// Must not be null to be active.
  ///
  /// E.g. use [Navigator.pop] to close the onboarding after navigating to it
  /// or use `setState` with changed state boolean to re-render the parent
  /// widget and conditionally display other widget instead of the onboarding.
  final VoidCallback? onPressedOnLastPage;
  final VoidCallback? onPressedOnFirstPage;

  final GlobalKey<FormState>? secondFormKey;
  final GlobalKey<FormState>? thirdFormKey;

  final String? editPageKey;

  @override
  State<CupertinoOnboarding> createState() => _CupertinoOnboardingState();
}

class _CupertinoOnboardingState extends State<CupertinoOnboarding> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  double _currentPageAsDouble = 0;

  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      setState(() {
        _currentPageAsDouble = _pageController.page!;
      });
    });
  }

  Widget backButton() {
    return Padding(
      padding: _kTopBackButtonPadding,
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.all(0),
              onPressed: () => {
                _currentPage == 0
                    ? widget.onPressedOnFirstPage!()
                    : widget.onPressed ?? _animateToPreviousPage(),
              },
              child: const Row(
                children: [
                  Icon(
                    CupertinoIcons.back,
                    color: CupertinoColors.black,
                  ),
                  SizedBox(width: 2),
                  Text(
                    backTitle,
                    style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w400,
                        color: CupertinoColors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ColoredBox(
          color:
              widget.backgroundColor ?? _kBackgroundColor.resolveFrom(context),
          child: SafeArea(
            child: Column(
              children: [
                backButton(),
                Expanded(
                  child: PageView(
                    physics: widget.scrollPhysics,
                    controller: _pageController,
                    children: widget.pages,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                  ),
                ),
                if (widget.pages.length > 1)
                  DotsIndicator(
                    dotsCount: widget.pages.length,
                    position: _currentPageAsDouble.toInt(),
                    decorator: DotsDecorator(
                      activeColor: _kActiveDotColor.resolveFrom(context),
                      color: _kInactiveDotColor.resolveFrom(context),
                      activeSize: _kDotSize,
                      size: _kDotSize,
                    ),
                  ),
                if (widget.widgetAboveBottomButton != null)
                  widget.widgetAboveBottomButton!
                else
                  const SizedBox(height: 15),
                Center(
                  child: Padding(
                    padding: widget.bottomButtonPadding,
                    child: Column(
                      children: [
                        CustomNextButton(
                          buttonTitle: _currentPage == widget.pages.length - 1
                              ? widget.editPageKey == null
                                  ? confirmAndPublishTitle
                                  : updateTitle
                              : nextTitle,
                          onPressedAction: () => {
                            if (widget.editPageKey != null)
                              {widget.onPressedOnLastPage!()}
                            else if (_currentPage == widget.pages.length - 1)
                              {
                                if (widget.thirdFormKey!.currentState!
                                    .validate())
                                  {widget.onPressedOnLastPage!()}
                              }
                            else if (_currentPage == 1)
                              {
                                if (widget.secondFormKey!.currentState!
                                    .validate())
                                  {
                                    widget.onPressed ?? _animateToNextPage(),
                                  }
                              }
                            else
                              {
                                widget.onPressed ?? _animateToNextPage(),
                              }
                          },
                        )
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: widget.bottomButtonPadding,
                    child: Column(
                      children: [
                        CustomBackButton(
                          onPressedAction: () => {
                            _currentPage == 0
                                ? widget.onPressedOnFirstPage!()
                                : widget.onPressed ?? _animateToPreviousPage(),
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Future<void> _animateToNextPage() async {
    await _pageController.nextPage(
      duration: widget.pageTransitionAnimationDuration,
      curve: widget.pageTransitionAnimationCurve,
    );
  }

  Future<void> _animateToPreviousPage() async {
    await _pageController.previousPage(
      duration: widget.pageTransitionAnimationDuration,
      curve: widget.pageTransitionAnimationCurve,
    );
  }
}
