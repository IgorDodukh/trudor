import 'package:flutter/cupertino.dart';
import 'package:spoto/core/constant/messages.dart';

final BorderRadius _bottomButtonBorderRadius = BorderRadius.circular(15);
const Duration pageTransitionAnimationDuration = Duration(milliseconds: 300);
const Curve pageTransitionAnimationCurve = Curves.fastEaseInToSlowEaseOut;

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressedAction;
  final PageController? pageController;

  const CustomBackButton({Key? key, this.onPressedAction, this.pageController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      borderRadius: _bottomButtonBorderRadius,
      color: CupertinoColors.white,
      padding: const EdgeInsets.all(0),
      onPressed: onPressedAction,
      child: Container(
        padding: const EdgeInsets.all(13), // add padding
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoColors.placeholderText,
            width: 1,
          ),
          borderRadius:
              const BorderRadius.all(Radius.circular(16)), // radius as you wish
        ),
        child: const DefaultTextStyle(
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          child: Row(
            children: [
              Spacer(),
              Text(goBackTitle, style: TextStyle(color: CupertinoColors.black)),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
