import 'package:email_validator/email_validator.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/data/models/user/user_model.dart';
import 'package:spoto/data/repositories/auth/google_auth_repository.dart';
import 'package:spoto/domain/auth/google_auth.dart';
import 'package:spoto/domain/usecases/auth/google_auth_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:spoto/presentation/blocs/home/navbar_cubit.dart';

import '../../../core/constant/images.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/usecases/user/sign_in_usecase.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../../widgets/input_form_button.dart';
import '../../widgets/input_text_form_field.dart';

class SignInView extends StatefulWidget {
  const SignInView({Key? key}) : super(key: key);

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        EasyLoading.dismiss();
        if (state is UserLoading) {
          EasyLoading.show(status: loadingTitle);
        } else if (state is UserLogged) {
          final userId = (context.read<UserBloc>().state.props.first as UserModel).id;
          context.read<FavoritesBloc>().add(GetFavorites(userId: userId));
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.home,
            ModalRoute.withName(''),
          );
        } else if (state is UserLoggedFail) {
          if (state.failure is CredentialFailure) {
            EasyLoading.showError("Username or Password is incorrect");
          } else {
            EasyLoading.showError("Something went wrong. Please try again or contact support.");
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
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
                    "Please enter your e-mail address and password to sign-in",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(
                    flex: 2,
                  ),
                  const SizedBox(
                    height: 24,
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
                    height: 12,
                  ),
                  InputTextFormField(
                    controller: passwordController,
                    hint: passwordHint,
                    isSecureField: true,
                    validation: (String? val) {
                      if (val == null || val.isEmpty) {
                        return "$passwordHint $fieldCantBeEmpty";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        // Navigator.pushNamed(context, AppRouter.forgotPassword);
                      },
                      child: const Text(
                        forgotPasswordTitle,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  InputFormButton(
                    color: Colors.black87,
                    onClick: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<UserBloc>().add(SignInUser(SignInParams(
                              username: emailController.text,
                              password: passwordController.text,
                            )));
                        context.read<NavbarCubit>().update(0);
                      }
                    },
                    titleText: 'Sign In',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InputFormButton(
                    color: Colors.black87,
                    onClick: () {
                      Navigator.of(context).pop();
                    },
                    titleText: 'Back',
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    height: 50,
                    child: SignInButton(
                      Buttons.google,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      text: "Continue with Google",
                      onPressed: () async {
                        final GoogleAuthRepository googleAuthRepository = GoogleAuthRepository();
                        final GoogleAuth? googleSignInUser = await googleAuthRepository.signIn();
                        if (googleSignInUser != null) {
                          context.read<UserBloc>().add(GoogleSignInUser(SignInGoogleParams(
                              id: googleSignInUser.id,
                              displayName: googleSignInUser.displayName,
                              email: googleSignInUser.email
                          )));
                          Navigator.pushNamed(context, AppRouter.home);
                          context.read<NavbarCubit>().update(0);
                        }
                      }
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, AppRouter.signUp);
                          },
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
