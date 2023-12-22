// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spoto/presentation/widgets/add_product_flow/constants.dart';

// Project imports:

const EdgeInsets _kOnboardingPagePadding = EdgeInsets.only(left: 25, right: 25);

const double _kTitleTopIndent = 50;

const double _kTitleToBodySpacing = 55;

/// Represents a swipeable page in the onboarding.
class CupertinoOnboardingPage extends StatelessWidget {
  /// Default constructor of the [CupertinoOnboardingPage] widget.
  const CupertinoOnboardingPage({
    required this.title,
    required this.body,
    this.bodyPadding = _kOnboardingPagePadding,
    this.titleTopIndent = _kTitleTopIndent,
    this.titleToBodySpacing = _kTitleToBodySpacing,
    this.bodyToBottomSpacing = 0,
    this.titleFlex = 3,
    super.key,
  });

  /// Title of the onboarding.
  ///
  /// It is recommended to keep it short.
  ///
  /// Defaults to Text("What's New").
  /// If another Text widget is provided, it will be
  /// defaultly styled to match the iOS 15 style onboarding.
  final Widget title;

  /// Body of the onboarding.
  final Widget body;

  /// Padding of the body.
  final EdgeInsets bodyPadding;

  /// Top indent of the title.
  ///
  /// Defaults to 80.
  final double titleTopIndent;

  /// Spacing between the title and the body.
  ///
  /// Defaults to 55.
  final double titleToBodySpacing;

  /// Spacing between the body and the bottom buttons/page indicator.
  ///
  /// Defaults to 0.
  final double bodyToBottomSpacing;

  /// Flex value of the title.
  ///
  /// Determines how much horizontal space the title takes.
  ///
  /// Defaults to 3.
  final int titleFlex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: titleTopIndent,
            bottom: titleToBodySpacing,
          ),
          child: DefaultTextStyle(
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kBaseTextColor.resolveFrom(context),
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              fontSize: 35,
            ),
            child: Row(
              children: [
                const Spacer(),
                Expanded(
                  flex: 6,
                  child: title,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 10,
          child: DefaultTextStyle(
            style: TextStyle(
              color: kBaseTextColor.resolveFrom(context),
            ),
            child: Padding(
              padding: bodyPadding,
              child: body,
            ),
          ),
        ),
        SizedBox(height: bodyToBottomSpacing),
      ],
    );
  }
}
