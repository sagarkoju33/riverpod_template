import 'dart:developer';

import 'package:auth_app/src/commons/providers/auth.dart';
import 'package:auth_app/src/commons/service/shared_preferences.dart';
import 'package:auth_app/src/features/auth/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  bool build() {
    return false;
  }

  Future<void> login({required String email, required String password}) async {
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.login(email: email, password: password);

    result.fold(
      (failure) {
        log("rtttttttttttttttttttttttttttt${failure.message}");
        // handle failure
      },
      (auth) {
        log("response???????????????????>>>>>>>>>>>>>>$auth");
        // ref.read(sharedPrefServiceProvider).saveAuth(auth);
        // ref.read(currentAuthProvider.notifier).setAuth(auth);
      },
    );
  }

  Future<void> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.signup(
      email: email,
      password: password,
      name: name,
    );

    result.fold(
      (failure) {
        // handle failure
      },
      (auth) {
        ref.read(sharedPrefServiceProvider).saveAuth(auth);
        ref.read(currentAuthProvider.notifier).setAuth(auth);
      },
    );
  }

  Future<void> signout() async {
    ref.read(sharedPrefServiceProvider).clearAuth();
    ref.read(currentAuthProvider.notifier).clearAuth();
  }
}
