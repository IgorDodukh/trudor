import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:trudor/core/error/failures.dart';
import 'package:trudor/core/usecases/usecase.dart';
import 'package:trudor/domain/usecases/auth/google_auth_usecase.dart';
import 'package:trudor/domain/usecases/user/get_cached_user_usecase.dart';
import 'package:trudor/domain/usecases/user/sign_in_usecase.dart';
import 'package:trudor/domain/usecases/user/sign_out_usecase.dart';
import 'package:trudor/domain/usecases/user/sign_up_usecase.dart';
import 'package:trudor/presentation/blocs/user/user_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../fixtures/constant_objects.dart';

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockGoogleAuthUseCase extends Mock implements GoogleAuthUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockGetCachedUserUseCase extends Mock implements GetCachedUserUseCase {}

void main() {
  group('UserBloc', () {
    late UserBloc userBloc;
    late MockSignInUseCase mockSignInUseCase;
    late MockGoogleAuthUseCase mockGoogleAuthUseCase;
    late MockSignUpUseCase mockSignUpUseCase;
    late MockSignOutUseCase mockSignOutUseCase;
    late MockGetCachedUserUseCase mockGetCachedUserUseCase;

    setUp(() {
      mockSignInUseCase = MockSignInUseCase();
      mockGoogleAuthUseCase = MockGoogleAuthUseCase();
      mockSignUpUseCase = MockSignUpUseCase();
      mockSignOutUseCase = MockSignOutUseCase();
      mockGetCachedUserUseCase = MockGetCachedUserUseCase();

      userBloc = UserBloc(
        mockSignInUseCase,
        mockGetCachedUserUseCase,
        mockSignOutUseCase,
        mockSignUpUseCase,
        mockGoogleAuthUseCase
      );
    });

    test('initial state should be UserInitial', () {
      expect(userBloc.state, UserInitial());
    });

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLogged] when SignInUser is added',
      build: () {
        when(() => mockSignInUseCase(tSignInParams))
            .thenAnswer((_) async => const Right(tUserModel));
        return userBloc;
      },
      act: (bloc) => bloc.add(SignInUser(tSignInParams)),
      expect: () => [UserLoading(), UserLogged(tUserModel)],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoggedOut] when SignOutUser is added',
      build: () {
        when(() => mockSignOutUseCase(NoParams()))
            .thenAnswer((_) async => Right(NoParams()));
        return userBloc;
      },
      act: (bloc) => bloc.add(SignOutUser()),
      expect: () => [UserLoading(), UserLoggedOut()],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLogged] when SignUpUser is added',
      build: () {
        when(() => mockSignUpUseCase(tSignUpParams))
            .thenAnswer((_) async => const Right(tUserModel));
        return userBloc;
      },
      act: (bloc) => bloc.add(SignUpUser(tSignUpParams)),
      expect: () => [UserLoading(), UserLogged(tUserModel)],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLogged] when CheckUser is added',
      build: () {
        when(() => mockGetCachedUserUseCase(NoParams()))
            .thenAnswer((_) async => const Right(tUserModel));
        return userBloc;
      },
      act: (bloc) => bloc.add(CheckUser()),
      expect: () => [UserLoading(), UserLogged(tUserModel)],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoggedFail] on SignInUser error',
      build: () {
        when(() => mockSignInUseCase(tSignInParams))
            .thenAnswer((_) async => Left(NetworkFailure()));
        return userBloc;
      },
      act: (bloc) => bloc.add(SignInUser(tSignInParams)),
      expect: () => [UserLoading(), UserLoggedFail(NetworkFailure())],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoggedFail] on SignUpUser error',
      build: () {
        when(() => mockSignUpUseCase(tSignUpParams))
            .thenAnswer((_) async => Left(NetworkFailure()));
        return userBloc;
      },
      act: (bloc) => bloc.add(SignUpUser(tSignUpParams)),
      expect: () => [UserLoading(), UserLoggedFail(NetworkFailure())],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoggedFail] on CheckUser error',
      build: () {
        when(() => mockGetCachedUserUseCase(NoParams()))
            .thenAnswer((_) async => Left(NetworkFailure()));
        return userBloc;
      },
      act: (bloc) => bloc.add(CheckUser()),
      expect: () => [UserLoading(), UserLoggedFail(NetworkFailure())],
    );
  });
}
