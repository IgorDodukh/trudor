import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:spoto/domain/usecases/auth/google_auth_usecase.dart';

import 'user_model.dart';

AuthenticationResponseModel authenticationResponseModelFromJson(String str) =>
    AuthenticationResponseModel.fromJson(json.decode(str));

AuthenticationResponseModel authenticationResponseModelFromUserCredential(
        User user) =>
    AuthenticationResponseModel.fromUserCredential(user);

AuthenticationResponseModel authenticationResponseModelFromGoogleParams(
        SignInGoogleParams params) =>
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

  factory AuthenticationResponseModel.fromUserCredential(User user) =>
      AuthenticationResponseModel(
          token: user.refreshToken!,
          user: UserModel(
            id: user.uid,
            firstName: user.displayName != null ? user.displayName!.split(" ").first : "",
            lastName: user.displayName != null ? user.displayName!.split(" ").last : "",
            email: user.email!,
            image: user.photoURL,
          ));

  factory AuthenticationResponseModel.fromGoogleParams(
      SignInGoogleParams params) {
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
