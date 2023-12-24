import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final BorderRadius _bottomButtonBorderRadius = BorderRadius.circular(16);
const Duration pageTransitionAnimationDuration = Duration(milliseconds: 300);
const Curve pageTransitionAnimationCurve = Curves.fastEaseInToSlowEaseOut;

class CustomNextButton extends StatelessWidget {
  final VoidCallback? onPressedAction;
  final PageController? pageController;
  final String buttonTitle;

  const CustomNextButton(
      {Key? key,
      this.onPressedAction,
      this.pageController,
      required this.buttonTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      borderRadius: _bottomButtonBorderRadius,
      color: Colors.black87,
      padding: const EdgeInsets.all(0),
      onPressed: onPressedAction,
      child: Container(
        padding: const EdgeInsets.all(16), // add padding
        decoration: const BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(16)), // radius as you wish
        ),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          child: Row(
            children: [
              const Spacer(),
              Text(buttonTitle,
                  style: const TextStyle(color: CupertinoColors.white)),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
