import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_status_controller.g.dart';

@Riverpod(keepAlive: true)
class InternetStatusController extends _$InternetStatusController {
  @override
  Stream<InternetStatus> build() {
    final connectionChecker = InternetConnection();

    return connectionChecker.onStatusChange;
  }
}
