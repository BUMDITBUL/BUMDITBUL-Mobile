import 'dart:io';

import 'package:bumditbul_mobile/core/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bumditbul_mobile/core/features/auth/domain/entities/user_entity.dart';
import 'package:bumditbul_mobile/core/features/auth/domain/repositories/auth_repository.dart';
import 'package:bumditbul_mobile/core/services/token_storage.dart';
import 'package:bumditbul_mobile/core/services/user_prefs.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;
  final UserPrefs userPrefs;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
    required this.userPrefs,
  });

  @override
  Future<bool> sendVerificationEmail({required String email}) =>
      remoteDataSource.sendVerificationEmail(email: email);

  @override
  Future<bool> verifyEmailCode({required String email, required String code}) =>
      remoteDataSource.verifyEmailCode(email: email, code: code);

  @override
  Future<User> signup({
    required String email,
    required String password,
    required String nickname,
    String? school,
  }) async {
    final tokens = await remoteDataSource.signup(
      email: email,
      password: password,
    );
    await tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    // 닉네임·학교를 서버에 저장
    await remoteDataSource.updateProfile(nickname: nickname, school: school);
    final user = await remoteDataSource.getProfile();
    await userPrefs.saveProfile(
      email: user.email,
      nickname: user.nickname,
      school: user.school,
    );
    return user;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    final tokens = await remoteDataSource.login(
      email: email,
      password: password,
    );
    await tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    final profile = await remoteDataSource.getProfile();
    await userPrefs.saveProfile(
      email: profile.email,
      nickname: profile.nickname,
      school: profile.school,
    );
    return profile;
  }

  @override
  Future<void> logout() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await remoteDataSource.logout(refreshToken: refreshToken);
      } catch (_) {}
    }
    await tokenStorage.clearTokens();
    await userPrefs.clear();
  }

  @override
  Future<void> withdraw() async {
    await remoteDataSource.withdraw();
    await tokenStorage.clearTokens();
    await userPrefs.clear();
  }

  @override
  Future<User?> getCurrentUser() async {
    final hasToken = await tokenStorage.hasTokens();
    if (!hasToken) return null;
    try {
      final profile = await remoteDataSource.getProfile();
      await userPrefs.saveProfile(
        email: profile.email,
        nickname: profile.nickname,
        school: profile.school,
      );
      return profile;
    } catch (_) {
      final saved = await userPrefs.loadProfile();
      if (saved == null) return null;
      return User(
        email: saved.email,
        nickname: saved.nickname,
        school: saved.school,
      );
    }
  }

  @override
  Future<User> loginWithGoogle({
    required String idToken,
    required String nickname,
    String? school,
  }) async {
    final tokens = await remoteDataSource.loginWithGoogle(idToken: idToken);
    await tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    final profile = await remoteDataSource.getProfile();
    await userPrefs.saveProfile(
      email: profile.email,
      nickname: profile.nickname,
      school: profile.school,
    );
    return profile;
  }

  @override
  Future<User> updateProfile({required String nickname, String? school}) async {
    final updated = await remoteDataSource.updateProfile(
      nickname: nickname,
      school: school,
    );
    await userPrefs.saveProfile(
      email: updated.email,
      nickname: updated.nickname,
      school: updated.school,
    );
    return updated;
  }

  @override
  Future<String> uploadProfileImage({required File image}) =>
      remoteDataSource.uploadProfileImage(image: image);
}
