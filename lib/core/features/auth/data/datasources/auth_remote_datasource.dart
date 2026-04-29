import 'dart:convert';
import 'dart:math';

import 'package:bumditbul_mobile/core/features/auth/data/models/user_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  /// 로그인 API 호출
  Future<UserModel> login({required String email, required String password});

  /// 회원가입 API 호출
  Future<UserModel> signup({
    required String email,
    required String password,
    required String nickname,
    String? school,
  });

  /// 사용자 정보 조회 API 호출
  Future<UserModel> getCurrentUser({required String token});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  String _generateSecureToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!email.contains('@')) {
        throw Exception('잘못된 이메일 형식입니다.');
      }
      if (password.length < 6) {
        throw Exception('비밀번호는 6자리 이상이어야 합니다.');
      }

      return UserModel(
        id: 'user_${email.split('@')[0]}',
        email: email,
        nickname: 'User_${DateTime.now().millisecondsSinceEpoch}',
        token: _generateSecureToken(),
      );
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<UserModel> signup({
    required String email,
    required String password,
    required String nickname,
    String? school,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!email.contains('@')) {
        throw Exception('잘못된 이메일 형식입니다.');
      }
      if (password.length < 6) {
        throw Exception('비밀번호는 6자리 이상이어야 합니다.');
      }
      if (nickname.isEmpty) {
        throw Exception('닉네임은 비어있을 수 없습니다.');
      }

      return UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        nickname: nickname,
        school: school,
        token: _generateSecureToken(),
      );
    } catch (e) {
      throw Exception('회원가입 오류: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser({required String token}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      // Validate token format
      if (token.isEmpty || token.length < 10) {
        throw Exception('유효하지 않은 토큰입니다.');
      }

      return UserModel(
        id: 'mock_user_id',
        email: 'user@example.com',
        nickname: 'Mock User',
        token: token,
      );
    } catch (e) {
      throw Exception('현재 사용자를 불러오지 못했습니다. $e');
    }
  }
}
