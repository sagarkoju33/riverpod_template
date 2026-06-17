import 'dart:developer';

import 'package:auth_app/src/features/auth/repository/endpoints.dart';
import 'package:auth_app/src/model/auth.dart';
import 'package:auth_app/src/model/failure.dart';
import 'package:auth_app/src/network/network.dart';
import 'package:auth_app/src/network/types.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(networkRepository: ref.watch(networkRepositoryProvider));

class AuthRepository {
  final NetworkRepository _networkRepository;

  AuthRepository({required NetworkRepository networkRepository})
    : _networkRepository = networkRepository;

  FutureEither<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final body = {"username": email, "password": password};
    final result = await _networkRepository.postRequest(
      url: AuthEndpoints.login,
      data: body,
    );

    return result.fold(
      (failure) {
        // handle failure
        return Left(failure);
      },
      (response) {
        // handle response
        try {
          final data = response.data;
          final auth = AuthResponse.fromJson(data);
          log("tttttttttttttttt${auth.data.token}");
          return Right(auth);
        } catch (e) {
          return Left(Failure(message: "Failed to parse response"));
        }
      },
    );
  }

  FutureEither<AuthResponse> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final body = {"name": name, "email": email, "password": password};
    final result = await _networkRepository.postRequest(
      url: AuthEndpoints.register,
      data: body,
    );

    return result.fold(
      (failure) {
        // handle failure
        return Left(failure);
      },
      (response) {
        // handle response
        try {
          final data = response.data;
          final auth = AuthResponse.fromJson(data);
          return Right(auth);
        } catch (e) {
          return Left(Failure(message: "Failed to parse response"));
        }
      },
    );
  }
}
