import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:spoto/domain/usecases/auth/google_auth_usecase.dart';
import 'package:spoto/domain/usecases/user/reset_password_usecase.dart';
import 'package:spoto/domain/usecases/user/send_reset_password_email_usecase.dart';
import 'package:spoto/domain/usecases/user/sign_out_usecase.dart';
import 'package:spoto/domain/usecases/user/sign_up_usecase.dart';
import 'package:spoto/domain/usecases/user/update_user_details_usecase.dart';
import 'package:spoto/domain/usecases/user/update_user_picture_usecase.dart';
import 'package:spoto/domain/usecases/user/validate_reset_password_code.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/user/user.dart';
import '../../../domain/usecases/user/get_cached_user_usecase.dart';
import '../../../domain/usecases/user/sign_in_usecase.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetCachedUserUseCase _getCachedUserUseCase;
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final UpdateUserDetailsUseCase _updateUserDetailsUseCase;
  final UpdateUserPictureUseCase _updateUserPictureUseCase;
  final GoogleAuthUseCase _googleAuthUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final SendResetPasswordEmailUseCase _sendResetPasswordEmailUseCase;
  final ValidateResetPasswordUseCase _validateResetPasswordUseCase;

  UserBloc(
      this._signInUseCase,
      this._getCachedUserUseCase,
      this._signOutUseCase,
      this._signUpUseCase,
      this._updateUserDetailsUseCase,
      this._updateUserPictureUseCase,
      this._googleAuthUseCase,
      this._resetPasswordUseCase,
      this._sendResetPasswordEmailUseCase,
      this._validateResetPasswordUseCase)
      : super(UserInitial()) {
    on<SignInUser>(_onSignIn);
    on<SignUpUser>(_onSignUp);
    on<CheckUser>(_onCheckUser);
    on<SignOutUser>(_onSignOut);
    on<UpdateUserDetails>(_onUpdateUserDetails);
    on<UpdateUserPicture>(_onUpdateUserPicture);
    on<GoogleSignInUser>(_onGoogleSignIn);
    on<ResetPassword>(_onResetPassword);
    on<SendResetPasswordEmail>(_onSendResetPasswordEmail);
    on<ValidateResetPasswordCode>(_onValidateResetPasswordCode);
  }

  void _onSignIn(SignInUser event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      final result = await _signInUseCase(event.params);
      result.fold(
        (failure) => emit(UserLoggedFail(failure)),
        (user) => emit(UserLogged(user)),
      );
    } catch (e) {
      emit(UserLoggedFail(ExceptionFailure()));
    }
  }

  void _onGoogleSignIn(GoogleSignInUser event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      final result = await _googleAuthUseCase(NoParams());
      result.fold(
        (failure) => emit(UserLoggedFail(failure)),
        (user) => emit(UserLogged(user)),
      );
    } catch (e) {
      emit(UserLoggedFail(ExceptionFailure()));
    }
  }

  void _onSignOut(SignOutUser event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      await _signOutUseCase(NoParams());
      emit(UserLoggedOut());
    } catch (e) {
      emit(UserLoggedFail(ExceptionFailure()));
    }
  }

  void _onUpdateUserDetails(
      UpdateUserDetails event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      final result = await _updateUserDetailsUseCase(event.params);
      print("Update result: $result");
      result.fold(
        (failure) => emit(UserUpdateFail(failure)),
        (user) => emit(UserLogged(user)),
      );
    } catch (e) {
      emit(UserUpdateFail(ExceptionFailure()));
    }
  }

  void _onUpdateUserPicture(
      UpdateUserPicture event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      final result = await _updateUserPictureUseCase(event.pictureUrl);
      result.fold(
        (failure) => emit(UserLoggedFail(failure)),
        (user) => emit(UserLogged(user)),
      );
    } catch (e) {
      emit(UserLoggedFail(ExceptionFailure()));
    }
  }

  void _onCheckUser(CheckUser event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      final result = await _getCachedUserUseCase(NoParams());
      result.fold(
        (failure) => emit(UserLoggedFail(failure)),
        (user) => emit(UserLogged(user)),
      );
    } catch (e) {
      emit(UserLoggedFail(ExceptionFailure()));
    }
  }

  FutureOr<void> _onSignUp(SignUpUser event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      final result = await _signUpUseCase(event.params);
      result.fold(
        (failure) => emit(UserLoggedFail(failure)),
        (user) => emit(UserLogged(user)),
      );
    } catch (e) {
      print("Sign up error _onSignUp: $e");
      emit(UserLoggedFail(ExceptionFailure()));
    }
  }

  FutureOr<void> _onResetPassword(
      ResetPassword event, Emitter<UserState> emit) async {
    try {
      emit(ResetPasswordLoading());
      final result = await _resetPasswordUseCase(event.params);
      result.fold(
        (failure) => emit(UserPasswordResetFail(failure)),
        (user) => emit(UserPasswordReset()),
      );
    } catch (e) {
      print("Reset password error _onResetPassword: $e");
      emit(UserLoggedFail(ExceptionFailure()));
    }
  }

  Future<FutureOr<void>> _onSendResetPasswordEmail(
      SendResetPasswordEmail event, Emitter<UserState> emit) async {
    try {
      emit(ResetPasswordSending());
      final result = await _sendResetPasswordEmailUseCase(event.email);
      result.fold(
        (failure) => emit(ResetPasswordFail(failure)),
        (user) => emit(ResetPasswordSent()),
      );
    } catch (e) {
      print("Sign up error _onSignUp: $e");
      emit(UserLoggedFail(ExceptionFailure()));
    }
  }

  Future<FutureOr<void>> _onValidateResetPasswordCode(
      ValidateResetPasswordCode event, Emitter<UserState> emit) async {
    try {
      emit(ResetPasswordLoading());
      await _validateResetPasswordUseCase(event.code);
      emit(UserPasswordReset());
    } catch (e) {
      print("Sign up error _onSignUp: $e");
      emit(UserLoggedFail(ExceptionFailure()));
    }
  }
}
