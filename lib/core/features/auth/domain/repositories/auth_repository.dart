import 'dart:io';

import 'package:bumditbul_mobile/core/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<bool> sendVerificationEmail({required String email});
  Future<bool> verifyEmailCode({required String email, required String code});
  Future<User> signup({
    required String email,
    required String password,
    required String nickname,
    String? school,
  });
  Future<User> login({required String email, required String password});
  Future<void> logout();
  Future<void> withdraw();
  Future<User?> getCurrentUser();
  Future<User> loginWithGoogle({
    required String idToken,
    required String nickname,
    String? school,
  });

  Future<User> updateProfile({required String nickname, String? school});

  Future<String> uploadProfileImage({required File image});
}
