import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String? image;
  final String email;
  final String? phoneNumber;
  final String? location;
  final bool? isDarkMode;
  final bool? enableNotification;

  const User({
    required this.id,
    required this.name,
    this.image,
    this.location,
    this.phoneNumber,
    this.isDarkMode,
    this.enableNotification,
    required this.email,
  });

  @override
  List<Object> get props => [
        id,
        name,
        email,
      ];
}
