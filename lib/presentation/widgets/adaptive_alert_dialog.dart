import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/router/app_router.dart';
import 'package:spoto/presentation/blocs/home/navbar_cubit.dart';

class AdaptiveDialog extends StatelessWidget {
  final String title;
  final String content;
  final String yes;
  final String no;
  final Function()? onClickYes;
  final Function()? onClickNo;

  const AdaptiveDialog(
      {super.key,
      this.onClickYes,
      this.onClickNo,
      required this.title,
      required this.content,
      required this.yes,
      required this.no});

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
            no,
          ),
        ),
        TextButton(
          onPressed: () {
            onClickYes!();
          },
          child: Text(yes, style: const TextStyle(color: Colors.red)),
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
      yes: discardChangesYes,
      no: goBackTitle,
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

class SignInToUseFeatureAlert extends StatelessWidget {
  final String contentText;

  const SignInToUseFeatureAlert({super.key, required this.contentText});

  @override
  Widget build(BuildContext context) {
    return AdaptiveDialog(
      title: wouldLikeToSignInTitle,
      content: contentText,
      yes: openSignInTitle,
      no: goBackTitle,
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
      yes: deactivateProductYes,
      no: goBackTitle,
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
      yes: activateProductYes,
      no: goBackTitle,
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

class SignOutConfirmationAlert extends StatelessWidget {
  final Function() onSignOut;

  const SignOutConfirmationAlert({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return AdaptiveDialog(
      title: signOutTitle,
      content: signOutConfirmContent,
      yes: signOutTitle,
      no: goBackTitle,
      onClickYes: () {
        onSignOut();
        EasyLoading.showSuccess(signOutSuccess);
        Navigator.of(context).pop();
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.home,
          ModalRoute.withName(''),
        );
        context.read<NavbarCubit>().update(0);
      },
      onClickNo: () {
        Navigator.of(context).pop();
      },
    );
  }
}
