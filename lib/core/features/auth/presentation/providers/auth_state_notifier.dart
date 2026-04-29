import 'package:bumditbul_mobile/core/features/auth/domain/entities/user_entity.dart';
import 'package:bumditbul_mobile/core/features/auth/domain/usecases/login_usecase.dart';
import 'package:bumditbul_mobile/core/features/auth/domain/usecases/signup_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState extends Equatable {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  List<Object?> get props => [user, isLoading, error, isAuthenticated];
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final SignupUseCase signupUseCase;

  AuthStateNotifier({required this.loginUseCase, required this.signupUseCase})
    : super(const AuthState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await loginUseCase(
        LoginParams(email: email, password: password),
      );

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String nickname,
    String? school,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await signupUseCase(
        SignupParams(email: email, password: password, nickname: nickname),
      );

      final userWithSchool = school != null && school.isNotEmpty
          ? user.copyWith(school: school)
          : user;

      state = state.copyWith(
        user: userWithSchool,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
    }
  }

  void updateProfile({required String nickname, String? school}) {
    if (state.user == null) return;
    state = state.copyWith(
      user: state.user!.copyWith(nickname: nickname, school: school),
    );
  }

  Future<void> logout() async {
    state = state.copyWith(user: null, isAuthenticated: false, error: null);
  }
}
