import 'package:bumditbul_mobile/core/features/auth/presentation/views/login_view.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/views/signup_view.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/views/splash_view.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/views/subject_grade_view.dart';
import 'package:bumditbul_mobile/core/features/exam_scope/presentation/views/exam_scope_view.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/views/home_view.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/views/main_view.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/views/profile_edit_view.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/views/profile_view.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/views/subject_grade_edit_view.dart';
import 'package:bumditbul_mobile/core/features/schedule/presentation/views/schedule_view.dart';
import 'package:bumditbul_mobile/core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupView(),
      ),
      GoRoute(
        path: AppRoutes.subjectGrade,
        builder: (context, state) {
          final userName = state.extra as String? ?? '';
          return SubjectGradeView(userName: userName);
        },
      ),
      GoRoute(
        path: AppRoutes.examScope,
        builder: (context, state) => const ExamScopeView(),
      ),
      GoRoute(
        path: AppRoutes.subjectGradeEdit,
        builder: (context, state) => const SubjectGradeEditView(),
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        builder: (context, state) => const ProfileEditView(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainView(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.main,
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: AppRoutes.schedule,
            builder: (context, state) => const ScheduleView(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileView(),
          ),
        ],
      ),
    ],
  );
});
