import 'dart:io';

import 'package:bumditbul_mobile/core/features/auth/domain/entities/user_entity.dart';
import 'package:bumditbul_mobile/core/features/auth/domain/repositories/auth_repository.dart';
import 'package:bumditbul_mobile/core/services/user_prefs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _unsetUser = Object();

class AuthState extends Equatable {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool isNewUser;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.isNewUser = false,
  });

  AuthState copyWith({
    Object? user = _unsetUser,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool? isNewUser,
  }) {
    return AuthState(
      user: user == _unsetUser ? this.user : user as User?,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  @override
  List<Object?> get props => [
    user,
    isLoading,
    error,
    isAuthenticated,
    isNewUser,
  ];
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthStateNotifier({
    required AuthRepository repo,
    required UserPrefs userPrefs,
  }) : _repo = repo,
       super(const AuthState());

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repo.getCurrentUser();
      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> sendVerificationEmail({required String email}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final isDuplicate = await _repo.sendVerificationEmail(email: email);
      state = state.copyWith(isLoading: false);
      return isDuplicate;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final verified = await _repo.verifyEmailCode(email: email, code: code);
      state = state.copyWith(isLoading: false);
      if (!verified) state = state.copyWith(error: '⚠︎ 인증번호가 올바르지 않습니다.');
      return verified;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.login(email: email, password: password);
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
      final user = await _repo.signup(
        email: email,
        password: password,
        nickname: nickname,
        school: school,
      );
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loginWithGoogle({
    required String idToken,
    required String email,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.loginWithGoogle(
        idToken: idToken,
        nickname: displayName ?? email.split('@').first,
      );
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        isNewUser: user.nickname.isEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile({required String nickname, String? school}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _repo.updateProfile(
        nickname: nickname,
        school: school,
      );
      state = state.copyWith(user: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> uploadProfileImage(File image) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final url = await _repo.uploadProfileImage(image: image);
      state = state.copyWith(
        user: state.user?.copyWith(profileImageUrl: url),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }

  Future<void> withdraw() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.withdraw();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}
