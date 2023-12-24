import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/core/usecases/usecase.dart';
import 'package:spoto/domain/usecases/auth/google_auth_usecase.dart';
import 'package:spoto/domain/usecases/user/get_cached_user_usecase.dart';
import 'package:spoto/domain/usecases/user/reset_password_usecase.dart';
import 'package:spoto/domain/usecases/user/send_reset_password_email_usecase.dart';
import 'package:spoto/domain/usecases/user/sign_in_usecase.dart';
import 'package:spoto/domain/usecases/user/sign_out_usecase.dart';
import 'package:spoto/domain/usecases/user/sign_up_usecase.dart';
import 'package:spoto/domain/usecases/user/update_user_details_usecase.dart';
import 'package:spoto/domain/usecases/user/update_user_picture_usecase.dart';
import 'package:spoto/domain/usecases/user/validate_reset_password_code.dart';
import 'package:spoto/presentation/blocs/user/user_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../fixtures/constant_objects.dart';

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockGoogleAuthUseCase extends Mock implements GoogleAuthUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

class MockSendResetPasswordEmailUseCase extends Mock
    implements SendResetPasswordEmailUseCase {}

class MockValidateResetPasswordUseCase extends Mock
    implements ValidateResetPasswordUseCase {}

class MockGetCachedUserUseCase extends Mock implements GetCachedUserUseCase {}

class MockUpdateUserDetailsUseCase extends Mock
    implements UpdateUserDetailsUseCase {}

class MockUpdateUserPictureUseCase extends Mock
    implements UpdateUserPictureUseCase {}

void main() {
  group('UserBloc', () {
    late UserBloc userBloc;
    late MockSignInUseCase mockSignInUseCase;
    late MockGoogleAuthUseCase mockGoogleAuthUseCase;
    late MockSignUpUseCase mockSignUpUseCase;
    late MockSignOutUseCase mockSignOutUseCase;
    late MockGetCachedUserUseCase mockGetCachedUserUseCase;
    late MockResetPasswordUseCase mockResetPasswordUseCase;
    late MockSendResetPasswordEmailUseCase mockSendResetPasswordEmailUseCase;
    late MockValidateResetPasswordUseCase mockValidateResetPasswordUseCase;
    late MockUpdateUserDetailsUseCase mockUpdateUserDetailsUseCase;
    late MockUpdateUserPictureUseCase mockUpdateUserPictureUseCase;

    setUp(() {
      mockSignInUseCase = MockSignInUseCase();
      mockGoogleAuthUseCase = MockGoogleAuthUseCase();
      mockSignUpUseCase = MockSignUpUseCase();
      mockSignOutUseCase = MockSignOutUseCase();
      mockGetCachedUserUseCase = MockGetCachedUserUseCase();
      mockResetPasswordUseCase = MockResetPasswordUseCase();
      mockSendResetPasswordEmailUseCase = MockSendResetPasswordEmailUseCase();
      mockValidateResetPasswordUseCase = MockValidateResetPasswordUseCase();
      mockUpdateUserDetailsUseCase = MockUpdateUserDetailsUseCase();
      mockUpdateUserPictureUseCase = MockUpdateUserPictureUseCase();

      userBloc = UserBloc(
        mockSignInUseCase,
        mockGetCachedUserUseCase,
        mockSignOutUseCase,
        mockSignUpUseCase,
        mockUpdateUserDetailsUseCase,
        mockUpdateUserPictureUseCase,
        mockGoogleAuthUseCase,
        mockResetPasswordUseCase,
        mockSendResetPasswordEmailUseCase,
        mockValidateResetPasswordUseCase,
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
