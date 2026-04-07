import 'package:bumditbul_mobile/core/features/auth/presentation/views/splash_view.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/views/login_view.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/views/signup_view.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/views/main_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupView(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainView(),
      ),
    ],
  );
});
