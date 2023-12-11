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
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: params.username, password: params.password);
      print("Sign in: ${credential.user}");
      if (credential.user != null) {
        return authenticationResponseModelFromUserCredential(credential.user!);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      } else {
        print("Sign in error: $e");
        throw CredentialFailure();
      }
    }
    print("Sign in error");
    throw const ServerException("Sign In Failed");
  }

  @override
  Future<AuthenticationResponseModel> signUp(params) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: params.email, password: params.password);

      User? user = credential.user;
      await user?.updateDisplayName("${params.firstName} ${params.lastName}");
      await user?.reload();

      User? latestUser = FirebaseAuth.instance.currentUser;
      if (latestUser != null) {
        return authenticationResponseModelFromUserCredential(latestUser);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        throw const ServerException("The password provided is too weak");
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        throw const ServerException(
            "The account already exists for that email");
      }
    } catch (e) {
      print(e);
    }
    throw const ServerException("Sign Up Failed");
  }

  @override
  Future<AuthenticationResponseModel> signInGoogle(
      SignInGoogleParams params) async {
    return authenticationResponseModelFromGoogleParams(params);
  }
}
