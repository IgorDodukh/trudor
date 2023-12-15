import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/domain/usecases/auth/google_auth_usecase.dart';
import 'package:spoto/domain/usecases/user/reset_password_usecase.dart';

import '../../../../core/error/exceptions.dart';
import '../../../domain/usecases/user/sign_in_usecase.dart';
import '../../../domain/usecases/user/sign_up_usecase.dart';
import '../../models/user/authentication_response_model.dart';

abstract class UserRemoteDataSource {
  Future<AuthenticationResponseModel> signIn(SignInParams params);

  Future<AuthenticationResponseModel> signInGoogle(SignInGoogleParams params);

  Future<AuthenticationResponseModel> signUp(SignUpParams params);

  Future<AuthenticationResponseModel> sendPasswordResetEmail(String email);

  Future<AuthenticationResponseModel> validateResetPasswordCode(String code);

  Future<AuthenticationResponseModel> resetPassword(ResetPasswordParams params);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;
  final _auth = FirebaseAuth.instance;

  UserRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthenticationResponseModel> signIn(params) async {
    UserCredential credential = await _auth
        .signInWithEmailAndPassword(
            email: params.username, password: params.password)
        .then((value) => value)
        .catchError((error) => handleSignInError(error));
    if (credential.user != null) {
      return authenticationResponseModelFromUserCredential(credential.user!);
    }
    throw const ServerException("Sign In Failed");
  }

  @override
  Future<AuthenticationResponseModel> signUp(params) async {
    UserCredential userCredential = await _auth
        .createUserWithEmailAndPassword(
            email: params.email, password: params.password)
        .then((value) => value)
        .catchError((error) => handleSignUpError(error));

    await userCredential.user
        ?.updateDisplayName("${params.firstName} ${params.lastName}");
    await userCredential.user?.reload();

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return authenticationResponseModelFromUserCredential(currentUser);
    }
    throw const ServerException("Sign Up Failed");
  }

  @override
  Future<AuthenticationResponseModel> sendPasswordResetEmail(email) async {
    await _auth
        .sendPasswordResetEmail(email: email)
        .then((value) => value)
        .catchError((error) => handleSendEmailError(error));

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return authenticationResponseModelFromUserCredential(currentUser);
    }
    throw const ServerException("Send password reset Failed");
  }

  @override
  Future<AuthenticationResponseModel> validateResetPasswordCode(code) async {
    await _auth
        .verifyPasswordResetCode(code)
        .then((value) => value)
        .catchError((error) => handleValidateCodeError(error));
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return authenticationResponseModelFromUserCredential(currentUser);
    }
    throw const ServerException("Validate reset password Failed");
  }

  @override
  Future<AuthenticationResponseModel> resetPassword(params) async {
    await _auth
        .confirmPasswordReset(
            code: params.resetCode, newPassword: params.newPassword)
        .then((value) => value)
        .catchError((error) => handleResetPasswordError(error));
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return authenticationResponseModelFromUserCredential(currentUser);
    }
    throw const ServerException("Reset password Failed");
  }

  @override
  Future<AuthenticationResponseModel> signInGoogle(
      SignInGoogleParams params) async {
    return authenticationResponseModelFromGoogleParams(params);
  }

  Future<UserCredential> handleSignInError(error) {
    if (error.code == 'user-not-found') {
      throw CredentialFailure();
    } else if (error.code == 'wrong-password') {
      throw CredentialFailure();
    } else {
      throw CredentialFailure();
    }
  }

  Future<UserCredential> handleSignUpError(error) {
    if (error.code == 'weak-password') {
      throw WeakPasswordFailure();
    } else if (error.code == 'email-already-in-use') {
      throw ExistingEmailFailure();
    } else if (error.code == 'invalid-email') {
      throw InvalidEmailFailure();
    } else {
      throw const ServerException("Sign Up Failed");
    }
  }

  Future<UserCredential> handleSendEmailError(error) {
    if (error.code == 'weak-password') {
      throw WeakPasswordFailure();
    } else if (error.code == 'email-already-in-use') {
      throw ExistingEmailFailure();
    } else if (error.code == 'invalid-email') {
      throw InvalidEmailFailure();
    } else {
      throw const ServerException("Send restore email Failed");
    }
  }

  Future<String> handleValidateCodeError(error) {
    if (error.code == 'weak-password') {
      throw WeakPasswordFailure();
    } else if (error.code == 'email-already-in-use') {
      throw ExistingEmailFailure();
    } else if (error.code == 'invalid-email') {
      throw InvalidEmailFailure();
    } else {
      throw const ServerException("Code validation Failed");
    }
  }

  Future<UserCredential> handleResetPasswordError(error) {
    if (error.code == 'weak-password') {
      throw WeakPasswordFailure();
    } else if (error.code == 'email-already-in-use') {
      throw ExistingEmailFailure();
    } else if (error.code == 'invalid-email') {
      throw InvalidEmailFailure();
    } else {
      throw const ServerException("Reset password Failed");
    }
  }
}
