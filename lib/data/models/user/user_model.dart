import 'dart:convert';

import 'package:spoto/domain/usecases/auth/google_auth_usecase.dart';

import '../../../domain/entities/user/user.dart';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel extends User {
  const UserModel({
    required String id,
    required String name,
    required String email,
    String? phoneNumber,
    String? image,
    String? location,
    bool? isDarkMode,
    bool? enableNotification,
  }) : super(
          id: id,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          image: image,
          location: location,
          isDarkMode: isDarkMode,
          enableNotification: enableNotification,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
      );

  factory UserModel.fromGoogleParams(SignInGoogleParams params) => UserModel(
        id: params.id,
        name: params.displayName,
        email: params.email,
        image: params.photoUrl,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
      };
}
