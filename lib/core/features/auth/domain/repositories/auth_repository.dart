import 'package:bumditbul_mobile/core/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});

  Future<User> signup({
    required String email,
    required String password,
    required String nickname,
  });

  Future<User?> getCurrentUser();

  Future<void> logout();

  Future<bool> isTokenValid();
}
