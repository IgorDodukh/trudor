import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:spoto/core/constant/strings.dart';
import 'package:spoto/core/error/exceptions.dart';
import 'package:spoto/core/error/failures.dart';
import 'package:spoto/data/data_sources/remote/user_remote_data_source.dart';
import 'package:spoto/data/models/user/authentication_response_model.dart';
import 'package:spoto/domain/usecases/user/sign_in_usecase.dart';
import 'package:spoto/domain/usecases/user/sign_up_usecase.dart';

import '../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late UserRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = UserRemoteDataSourceImpl(client: mockHttpClient);
  });

  group('signIn', () {
    test(
        'should perform a POST request to the correct URL with the given parameters',
        () async {
      /// Arrange
      const fakeParams =
          SignInParams(username: 'username', password: 'password');
      const expectedUrl = '$baseUrl/authentication/local/sign-in';
      final fakeResponse = fixture('user/authentication_response.json');
      when(() => mockHttpClient.post(
            Uri.parse(expectedUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'identifier': fakeParams.username,
              'password': fakeParams.password,
            }),
          )).thenAnswer((_) async => http.Response(fakeResponse, 200));

      /// Act
      final result = await dataSource.signIn(fakeParams);

      /// Assert
      verify(() => mockHttpClient.post(
            Uri.parse(expectedUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'identifier': fakeParams.username,
              'password': fakeParams.password,
            }),
          ));
      expect(result, isA<AuthenticationResponseModel>());
    });

    test('should throw a CredentialFailure on 400 or 401 status code',
        () async {
      /// Arrange
      const fakeParams =
          SignInParams(username: 'username', password: 'password');
      const expectedUrl = '$baseUrl/authentication/local/sign-in';
      when(() => mockHttpClient.post(
            Uri.parse(expectedUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'identifier': fakeParams.username,
              'password': fakeParams.password,
            }),
          )).thenAnswer((_) async => http.Response('Error message', 400));

      /// Act
      final result = dataSource.signIn(fakeParams);

      /// Assert
      expect(result, throwsA(isA<CredentialFailure>()));
    });

    test(
        'should throw a ServerException on non-200 status code other than 400 or 401',
        () async {
      /// Arrange
      const fakeParams =
          SignInParams(username: 'username', password: 'password');
      const expectedUrl = '$baseUrl/authentication/local/sign-in';
      when(() => mockHttpClient.post(
            Uri.parse(expectedUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'identifier': fakeParams.username,
              'password': fakeParams.password,
            }),
          )).thenAnswer((_) async => http.Response('Error message', 404));

      /// Act
      final result = dataSource.signIn(fakeParams);

      /// Assert
      expect(result, throwsA(isA<ServerException>()));
    });
  });

  group('signUp', () {
    test(
        'should perform a POST request to the correct URL with the given parameters',
        () async {
      /// Arrange
      const fakeParams = SignUpParams(
        name: 'John',
        email: 'john.doe@example.com',
        password: 'password',
      );
      const expectedUrl = '$baseUrl/authentication/local/sign-up';
      final fakeResponse = fixture('user/authentication_response.json');
      when(() => mockHttpClient.post(
            Uri.parse(expectedUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'name': fakeParams.name,
              'email': fakeParams.email,
              'password': fakeParams.password,
            }),
          )).thenAnswer((_) async => http.Response(fakeResponse, 200));

      /// Act
      final result = await dataSource.signUp(fakeParams);

      /// Assert
      verify(() => mockHttpClient.post(
            Uri.parse(expectedUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'name': fakeParams.name,
              'email': fakeParams.email,
              'password': fakeParams.password,
            }),
          ));
      expect(result, isA<AuthenticationResponseModel>());
    });

    test('should throw a CredentialFailure on 400 or 401 status code',
        () async {
      /// Arrange
      const fakeParams = SignUpParams(
        name: 'John',
        email: 'john.doe@example.com',
        password: 'password',
      );
      const expectedUrl = '$baseUrl/authentication/local/sign-up';
      when(() => mockHttpClient.post(
            Uri.parse(expectedUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'name': fakeParams.name,
              'email': fakeParams.email,
              'password': fakeParams.password,
            }),
          )).thenAnswer((_) async => http.Response('Error message', 400));

      /// Act
      final result = dataSource.signUp(fakeParams);

      /// Assert
      expect(result, throwsA(isA<CredentialFailure>()));
    });

    test(
        'should throw a ServerException on non-200 status code other than 400 or 401',
        () async {
      /// Arrange
      const fakeParams = SignUpParams(
        name: 'John Doe',
        email: 'john.doe@example.com',
        password: 'password',
      );
      const expectedUrl = '$baseUrl/authentication/local/sign-up';
      when(() => mockHttpClient.post(
            Uri.parse(expectedUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'name': fakeParams.name,
              'email': fakeParams.email,
              'password': fakeParams.password,
            }),
          )).thenAnswer((_) async => http.Response('Error message', 404));

      /// Act
      final result = dataSource.signUp(fakeParams);

      /// Assert
      expect(result, throwsA(isA<ServerException>()));
    });
  });
}
