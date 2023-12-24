import 'package:dartz/dartz.dart';
import 'package:spoto/core/usecases/usecase.dart';

import '../../../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../data_sources/local/user_local_data_source.dart';
import '../data_sources/remote/user_remote_data_source.dart';
import '../models/user/authentication_response_model.dart';

typedef _DataSourceChooser = Future<AuthenticationResponseModel> Function();

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> signIn(params) async {
    return await _authenticate(() {
      return remoteDataSource.signIn(params);
    });
  }

  @override
  Future<Either<Failure, User>> signUp(params) async {
    return await _authenticate(() {
      return remoteDataSource.signUp(params);
    });
  }

  @override
  Future<Either<Failure, User>> updateUserDetails(params) async {
    return await _authenticate(() {
      return remoteDataSource.updateUserDetails(params);
    });
  }

  @override
  Future<Either<Failure, User>> updateUserPicture(params) async {
    return await _authenticate(() {
      return remoteDataSource.updateUserPicture(params);
    });
  }

  @override
  Future<Either<Failure, User>> getCachedUser() async {
    try {
      final user = await localDataSource.getUser();
      return Right(user);
    } on CacheFailure {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, NoParams>> signOut() async {
    try {
      await localDataSource.clearCache();
      return Right(NoParams());
    } on CacheFailure {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, NoParams>> sendPasswordResetEmail(email) async {
    try {
      await _authenticate(() {
        return remoteDataSource.sendPasswordResetEmail(email);
      });
      return Right(NoParams());
    } on Failure {
      return Left(SendResetPasswordEmailFailure());
    }
  }

  @override
  Future<Either<Failure, NoParams>> validateResetPasswordCode(code) async {
    try {
      await _authenticate(() {
        return remoteDataSource.validateResetPasswordCode(code);
      });
      return Right(NoParams());
    } on Failure {
      return Left(SendResetPasswordEmailFailure());
    }
  }

  @override
  Future<Either<Failure, NoParams>> resetPassword(params) async {
    try {
      await _authenticate(() {
        return remoteDataSource.resetPassword(params);
      });
      return Right(NoParams());
    } on Failure {
      return Left(SendResetPasswordEmailFailure());
    }
  }

  Future<Either<Failure, User>> _authenticate(
    _DataSourceChooser getDataSource,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteResponse = await getDataSource();
        localDataSource.saveToken(remoteResponse.token);
        localDataSource.saveUser(remoteResponse.user);
        return Right(remoteResponse.user);
      } on Failure catch (failure) {
        return Left(failure);
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> googleSignIn(NoParams params) async {
    return await _authenticate(() {
      return remoteDataSource.signInGoogle(params);
    });
  }
}
