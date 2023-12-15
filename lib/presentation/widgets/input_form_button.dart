import 'package:flutter/material.dart';
import 'package:spoto/core/constant/images.dart';

class InputFormButton extends StatelessWidget {
  final Function() onClick;
  final String? titleText;
  final Icon? icon;
  final Color? color;
  final Color? textColor;
  final double? cornerRadius;
  final EdgeInsets padding;

  const InputFormButton(
      {Key? key,
      required this.onClick,
      this.titleText,
      this.icon,
      this.color,
      this.textColor,
      this.cornerRadius,
      this.padding = const EdgeInsets.symmetric(horizontal: 16)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onClick,
      style: ButtonStyle(
        surfaceTintColor: MaterialStateProperty.all<Color>(Colors.transparent),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
        padding: MaterialStateProperty.all<EdgeInsets>(padding),
        maximumSize:
            MaterialStateProperty.all<Size>(const Size(double.maxFinite, 50)),
        minimumSize:
            MaterialStateProperty.all<Size>(const Size(double.maxFinite, 50)),
        backgroundColor: MaterialStateProperty.all<Color>(
            color ?? Theme.of(context).primaryColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius ?? 16.0)),
        ),
        elevation: MaterialStateProperty.all<double>(0),
        side: MaterialStateProperty.all<BorderSide>(
            const BorderSide(color: Colors.black12)),
      ),
      child: titleText != null
          ? Text(
              titleText!,
              style: TextStyle(color: textColor ?? Colors.white, fontSize: 16),
            )
          : Image.asset(
              kFilterIcon,
              color: Colors.white,
            ),
    );
  }
}
