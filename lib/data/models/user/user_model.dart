import 'dart:convert';

import 'package:spoto/domain/usecases/auth/google_auth_usecase.dart';

import '../../../domain/entities/user/user.dart';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel extends User {
  const UserModel({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
  }) : super(
    id: id,
    firstName: firstName,
    lastName: lastName,
    email: email,
    phoneNumber: phoneNumber,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["_id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
  );

  factory UserModel.fromGoogleParams(SignInGoogleParams params) => UserModel(
    id: params.id,
    firstName: params.displayName.split(" ").first,
    lastName: params.displayName.split(" ").last,
    email: params.email,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
  };
}
