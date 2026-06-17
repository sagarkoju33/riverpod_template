import 'package:auth_app/src/features/auth/view/login_view.dart';
import 'package:auth_app/src/features/auth/view/signup_view.dart';
import 'package:auth_app/src/features/feed/view/feed_view.dart';
import 'package:auth_app/src/model/auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'auth_router.g.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
GoRouter authRouter(Ref ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: LoginView.routePath,

    routes: [
      GoRoute(
        path: LoginView.routePath,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: SignupView.routePath,
        builder: (context, state) => const SignupView(),
      ),
      GoRoute(
        path: FeedView.routePath,
        builder: (context, state) {
          return FeedView();
        },
      ),
      // GoRoute(
      //   path: FeedView.routePath,
      //   builder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>?;
      //     final title = extra?['title'] ?? 'Feed';
      //     return FeedView(title: title);
      //   },
      // ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Text('Page not found: ${state.error}')),
  );
}
