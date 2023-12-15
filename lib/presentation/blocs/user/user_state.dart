part of 'user_bloc.dart';

@immutable
abstract class UserState extends Equatable {}

class UserInitial extends UserState {
  @override
  List<Object> get props => [];
}

class UserLoading extends UserState {
  @override
  List<Object> get props => [];
}

class ResetPasswordSending extends UserState {
  @override
  List<Object> get props => [];
}

class ResetPasswordSent extends UserState {
  @override
  List<Object> get props => [];
}

class ResetPasswordLoading extends UserState {
  @override
  List<Object> get props => [];
}

class ResetPasswordFail extends UserState {
  final Failure failure;
  ResetPasswordFail(this.failure);
  @override
  List<Object> get props => [];
}

class UserLogged extends UserState {
  final User user;
  UserLogged(this.user);
  @override
  List<Object> get props => [user];
}

class UserPasswordReset extends UserState {
  // final User user;
  UserPasswordReset();
  @override
  List<Object> get props => [];
}

class UserLoggedFail extends UserState {
  final Failure failure;
  UserLoggedFail(this.failure);
  @override
  List<Object> get props => [failure];
}

class UserPasswordResetFail extends UserState {
  final Failure failure;
  UserPasswordResetFail(this.failure);
  @override
  List<Object> get props => [failure];
}

class UserLoggedOut extends UserState {
  @override
  List<Object> get props => [];
}
