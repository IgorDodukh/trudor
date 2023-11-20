import 'dart:convert';

import 'package:trudor/core/error/failures.dart';
import 'package:trudor/domain/usecases/auth/google_auth_usecase.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../../../core/constant/strings.dart';
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

  UserRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthenticationResponseModel> signIn(params) => _authenticate(
        '$baseUrl/authentication/local/sign-in',
        {
          'identifier': params.username,
          'password': params.password,
        },
      );

  @override
  Future<AuthenticationResponseModel> signUp(params) => _authenticate(
        '$baseUrl/authentication/local/sign-up',
        {
          'firstName': params.firstName,
          'lastName': params.lastName,
          'email': params.email,
          'password': params.password,
        },
      );

  Future<AuthenticationResponseModel> _authenticate(
      String url, Map<String, dynamic> body) async {
    final response = await client.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body));
    if (response.statusCode == 200) {
      return authenticationResponseModelFromJson(response.body);
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      throw CredentialFailure();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<AuthenticationResponseModel> signInGoogle(
      SignInGoogleParams params) async {
    return authenticationResponseModelFromGoogleParams(params);
  }
}
