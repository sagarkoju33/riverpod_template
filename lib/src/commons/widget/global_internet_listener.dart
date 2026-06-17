import 'package:auth_app/src/commons/controller/network_status_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class GlobalInternetListener extends ConsumerWidget {
  final Widget child;

  const GlobalInternetListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the stream
    ref.listen(internetStatusControllerProvider, (previous, next) {
      next.whenData((status) {
        // Prevent spamming: only act if status CHANGED
        if (previous?.value == status) return;

        if (status == InternetStatus.disconnected) {
          _showOfflineSnackbar(context);
        } else if (status == InternetStatus.connected &&
            previous?.value == InternetStatus.disconnected) {
          _showOnlineSnackbar(context);
        }
      });
    });

    return child;
  }

  void _showOfflineSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 8),
            Text('No internet connection'),
          ],
        ),
        backgroundColor: Colors.redAccent,
        duration: Duration(days: 365), // Stays until dismissed or online
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  void _showOnlineSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Back online'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
