import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/router/app_router.dart';

class AdaptiveDialog extends StatelessWidget {
  final String title;
  final String content;
  final String yesButtonTitle;
  final String noButtonTitle;
  final Function()? onClickYes;
  final Function()? onClickNo;

  const AdaptiveDialog(
      {super.key,
      this.onClickYes,
      this.onClickNo,
      required this.title,
      required this.content,
      required this.yesButtonTitle,
      required this.noButtonTitle});

  Widget adaptiveAction(
      {required BuildContext context,
      required VoidCallback onPressed,
      required Widget child}) {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return TextButton(onPressed: onPressed, child: child);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoDialogAction(onPressed: onPressed, child: child);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            onClickNo!();
          },
          child: Text(
            noButtonTitle,
            style: const TextStyle(color: Colors.red),
          ),
        ),
        TextButton(
          onPressed: () {
            onClickYes!();
          },
          child: Text(yesButtonTitle),
        ),
      ],
    );
  }
}

class DiscardChangesAlert extends StatelessWidget {
  const DiscardChangesAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveDialog(
      title: discardChangesTitle,
      content: discardChangesContent,
      yesButtonTitle: discardChangesYes,
      noButtonTitle: discardChangesNo,
      onClickYes: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
      onClickNo: () {
        Navigator.of(context).pop();
      },
    );
  }
}

class UnauthorisedAddFavoritesAlert extends StatelessWidget {
  const UnauthorisedAddFavoritesAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveDialog(
      title: addFavoritesTitle,
      content: addFavoritesContent,
      yesButtonTitle: addFavoritesYes,
      noButtonTitle: addFavoritesNo,
      onClickYes: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(AppRouter.signIn);
      },
      onClickNo: () {
        Navigator.of(context).pop();
      },
    );
  }
}

class DeactivateProductAlert extends StatelessWidget {
  final Function() onDeactivateProduct;

  const DeactivateProductAlert({super.key, required this.onDeactivateProduct});

  @override
  Widget build(BuildContext context) {
    return AdaptiveDialog(
      title: deactivateProductTitle,
      content: deactivateProductContent,
      yesButtonTitle: deactivateProductYes,
      noButtonTitle: deactivateProductNo,
      onClickYes: () {
        onDeactivateProduct();
        EasyLoading.showSuccess(deactivatedSuccessfully);
        Navigator.of(context).pop();
      },
      onClickNo: () {
        Navigator.of(context).pop();
      },
    );
  }
}

class RenewProductAlert extends StatelessWidget {
  final Function() onRenewProduct;

  const RenewProductAlert({super.key, required this.onRenewProduct});

  @override
  Widget build(BuildContext context) {
    return AdaptiveDialog(
      title: activateProductTitle,
      content: activateProductContent,
      yesButtonTitle: activateProductYes,
      noButtonTitle: activateProductNo,
      onClickYes: () {
        onRenewProduct();
        EasyLoading.showSuccess(productPublishedSuccessfully);
        Navigator.of(context).pop();
      },
      onClickNo: () {
        Navigator.of(context).pop();
      },
    );
  }
}
