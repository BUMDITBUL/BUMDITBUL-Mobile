import 'package:bumditbul_mobile/core/features/auth/presentation/views/splash_view.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/views/login_view.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/views/signup_view.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/views/subject_grade_view.dart';
import 'package:bumditbul_mobile/core/features/exam_scope/presentation/views/exam_scope_view.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/views/home_view.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/views/main_view.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/views/profile_edit_view.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/views/profile_view.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/views/subject_grade_edit_view.dart';
import 'package:bumditbul_mobile/core/features/schedule/presentation/views/schedule_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashView()),
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupView()),
      GoRoute(
        path: '/subject-grade',
        builder: (context, state) {
          final userName = state.extra as String? ?? '';
          return SubjectGradeView(userName: userName);
        },
      ),
      GoRoute(
        path: '/exam-scope',
        builder: (context, state) => const ExamScopeView(),
      ),
      GoRoute(
        path: '/subject-grade-edit',
        builder: (context, state) => const SubjectGradeEditView(),
      ),
      GoRoute(
        path: '/profile-edit',
        builder: (context, state) => const ProfileEditView(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainView(child: child),
        routes: [
          GoRoute(path: '/main', builder: (context, state) => const HomeView()),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const ScheduleView(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileView(),
          ),
        ],
      ),
    ],
  );
});
