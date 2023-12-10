import 'dart:convert';

import 'package:spoto/domain/usecases/auth/google_auth_usecase.dart';

import 'user_model.dart';

AuthenticationResponseModel authenticationResponseModelFromJson(String str) =>
    AuthenticationResponseModel.fromJson(json.decode(str));

AuthenticationResponseModel authenticationResponseModelFromGoogleParams(SignInGoogleParams params) =>
    AuthenticationResponseModel.fromGoogleParams(params);

String authenticationResponseModelToJson(AuthenticationResponseModel data) =>
    json.encode(data.toJson());

class AuthenticationResponseModel {
  final String token;
  final UserModel user;

  const AuthenticationResponseModel({
    required this.token,
    required this.user,
  });

  factory AuthenticationResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthenticationResponseModel(
        token: json["token"],
        user: UserModel.fromJson(json["user"]),
      );

  factory AuthenticationResponseModel.fromGoogleParams(SignInGoogleParams params) {
    return AuthenticationResponseModel(
      token: "no-token",
      user: UserModel.fromGoogleParams(params),
    );

  }

  Map<String, dynamic> toJson() => {
        "token": token,
        "user": user.toJson(),
      };
}
