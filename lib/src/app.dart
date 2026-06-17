import 'package:auth_app/src/commons/controller/init_controller.dart';
import 'package:auth_app/src/commons/providers/auth.dart';
import 'package:auth_app/src/commons/widget/global_internet_listener.dart';
import 'package:auth_app/src/resources/theme.dart';
import 'package:auth_app/src/utils/auth_router.dart';
import 'package:auth_app/src/utils/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Application extends ConsumerStatefulWidget {
  const Application({super.key});

  @override
  ConsumerState<Application> createState() => _ApplicationState();
}

class _ApplicationState extends ConsumerState<Application> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(initControllerProvider).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(currentAuthProvider);

    final router = ref.watch(goRouterProvider);
    final authRouter = ref.watch(authRouterProvider);

    // some logic that will decide weather to show authRoutes, or regular routes

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,
      routerConfig: authRouter,

      // routerConfig: auth == null ? authRouter : router,
      builder: (context, child) => GlobalInternetListener(child: child!),
    );
  }
}
