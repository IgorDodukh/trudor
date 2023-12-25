import 'package:flutter/cupertino.dart';
import 'package:spoto/core/constant/messages.dart';

class TopBackButton extends StatelessWidget {
  final String? buttonTitle;

  const TopBackButton({super.key, this.buttonTitle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          CupertinoButton(
            padding: const EdgeInsets.all(0),
            onPressed: () => {
              Navigator.of(context).pop(),
            },
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.back,
                  color: CupertinoColors.black,
                ),
                const SizedBox(width: 2),
                Text(
                  buttonTitle ?? backTitle,
                  style: const TextStyle(
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
    );
  }
}
