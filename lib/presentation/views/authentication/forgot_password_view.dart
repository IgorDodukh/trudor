import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/data/models/user/user_model.dart';
import 'package:spoto/presentation/blocs/user/user_bloc.dart';

import '../../../core/constant/images.dart';
import '../../../core/error/failures.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../widgets/input_form_button.dart';
import '../../widgets/input_text_form_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        EasyLoading.dismiss();
        if (state is ResetPasswordSending) {
          EasyLoading.show(status: loadingTitle);
        } else if (state is ResetPasswordSent) {
          EasyLoading.showSuccess(
              "Please check your mailbox for reset password link");
        } else if (state is ResetPasswordFail) {
          if (state.failure is ServerFailure) {
            EasyLoading.showError("Error: ${state.toString()}");
          } else if (state.failure is InvalidEmailFailure) {
            EasyLoading.showError(
                "The email address is not valid! Please try again.");
          } else {
            EasyLoading.showError(
                "Something went wrong. Please try again or contact support");
          }
        }
        if (state is UserLoading) {
          EasyLoading.show(status: loadingTitle);
        } else if (state is UserLogged) {
          final userId =
              (context.read<UserBloc>().state.props.first as UserModel).id;
          context.read<FavoritesBloc>().add(GetFavorites(userId: userId));
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.home,
            ModalRoute.withName(''),
          );
        } else if (state is UserLoggedFail) {
          if (state.failure is CredentialFailure) {
            EasyLoading.showError("Username/Password Wrong!");
          } else if (state.failure is ServerFailure) {
            EasyLoading.showError("Error: ${state.toString()}");
          } else if (state.failure is WeakPasswordFailure) {
            EasyLoading.showError(
                "Provided password is too weak. Please try more complex password.");
          } else if (state.failure is ExistingEmailFailure) {
            EasyLoading.showError(
                "The account with this email already exists.");
          } else if (state.failure is InvalidEmailFailure) {
            EasyLoading.showError(
                "The email address is not valid! Please try again.");
          } else {
            EasyLoading.showError(
                "Something went wrong. Please try again or contact support");
          }
        }
      },
      child: Scaffold(
          body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                      height: 80,
                      child: Image.asset(
                        kAppLogo,
                        color: Colors.black,
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Please enter registered e-mail address to restore your password",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  InputTextFormField(
                    textInputType: TextInputType.emailAddress,
                    controller: emailController,
                    hint: emailHint,
                    maxCharacters: 256,
                    validation: (String? val) {
                      if (val == null || val.isEmpty) {
                        return "$emailHint $fieldCantBeEmpty";
                      } else if (!EmailValidator.validate(val)) {
                        return invalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InputFormButton(
                    color: Colors.black87,
                    onClick: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<UserBloc>().add(SendResetPasswordEmail(
                              emailController.text,
                            ));
                        // context.read<NavbarCubit>().update(0);
                      }
                    },
                    titleText: sendConfirmEmailTitle,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InputFormButton(
                    color: Colors.white,
                    textColor: Colors.black87,
                    onClick: () {
                      Navigator.of(context).pop();
                    },
                    titleText: backTitle,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }
}
