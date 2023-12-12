import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/domain/usecases/auth/google_auth_usecase.dart';

import '../../../../core/error/exceptions.dart';
import '../../../domain/usecases/user/sign_in_usecase.dart';
import '../../../domain/usecases/user/sign_up_usecase.dart';
import '../../models/user/authentication_response_model.dart';

abstract class UserRemoteDataSource {
  Future<AuthenticationResponseModel> signIn(SignInParams params);

  Future<AuthenticationResponseModel> signInGoogle(SignInGoogleParams params);

  Future<AuthenticationResponseModel> signUp(SignUpParams params);
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

    User? latestUser = FirebaseAuth.instance.currentUser;
    if (latestUser != null) {
      return authenticationResponseModelFromUserCredential(latestUser);
    }
    throw const ServerException("Sign Up Failed");
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
}
