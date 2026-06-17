import 'package:auth_app/src/features/auth/view/login_view.dart';
import 'package:auth_app/src/features/auth/view/signup_view.dart';
import 'package:auth_app/src/features/feed/view/feed_view.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'auth_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter authRouter(Ref ref) => GoRouter(
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
      builder: (context, state) => const FeedView(),
    ),
  ],
);
