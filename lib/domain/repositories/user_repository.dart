import 'package:dartz/dartz.dart';
import 'package:spoto/domain/usecases/auth/google_auth_usecase.dart';
import 'package:spoto/domain/usecases/user/reset_password_usecase.dart';

import '../../../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/user/user.dart';
import '../usecases/user/sign_in_usecase.dart';
import '../usecases/user/sign_up_usecase.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> googleSignIn(SignInGoogleParams params);
  Future<Either<Failure, User>> signIn(SignInParams params);
  Future<Either<Failure, User>> signUp(SignUpParams params);
  Future<Either<Failure, NoParams>> sendPasswordResetEmail(String email);
  Future<Either<Failure, NoParams>> validateResetPasswordCode(String code);
  Future<Either<Failure, NoParams>> resetPassword(ResetPasswordParams params);
  Future<Either<Failure, NoParams>> signOut();
  Future<Either<Failure, User>> getCachedUser();
}
