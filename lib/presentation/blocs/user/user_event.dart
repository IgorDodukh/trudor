part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class SignInUser extends UserEvent {
  final SignInParams params;
  SignInUser(this.params);
}

class SignUpUser extends UserEvent {
  final SignUpParams params;
  SignUpUser(this.params);
}

class SignOutUser extends UserEvent {}

class GoogleSignInUser extends UserEvent {
  final SignInGoogleParams params;
  GoogleSignInUser(this.params);
}

class ResetPassword extends UserEvent {
  final ResetPasswordParams params;
  ResetPassword(this.params);
}

class SendResetPasswordEmail extends UserEvent {
  final String email;
  SendResetPasswordEmail(this.email);
}

class ValidateResetPasswordCode extends UserEvent {
  final String code;
  ValidateResetPasswordCode(this.code);
}

class CheckUser extends UserEvent {}
