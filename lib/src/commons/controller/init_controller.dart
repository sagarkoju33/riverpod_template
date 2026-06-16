import 'package:auth_app/src/commons/providers/auth.dart';
import 'package:auth_app/src/commons/service/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'init_controller.g.dart';

@Riverpod(keepAlive: true)
InitController initController(Ref ref) {
  return InitController(ref: ref);
}

class InitController {
  final Ref _ref;

  InitController({required Ref ref}) : _ref = ref;

  Future<void> init() async {
    final auth = await _ref.read(sharedPrefServiceProvider).getAuth();
    if (auth != null) {
      _ref.read(currentAuthProvider.notifier).setAuth(auth);
    }
  }
}
