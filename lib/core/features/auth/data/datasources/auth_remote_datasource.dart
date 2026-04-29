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
  });

  /// 사용자 정보 조회 API 호출
  Future<UserModel> getCurrentUser({required String token});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

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
        throw Exception('비밀번호는 6자리 이하일 수 없습니다.');
      }

      return UserModel(
        id: 'user_${email.split('@')[0]}',
        email: email,
        nickname: 'User_${DateTime.now().millisecondsSinceEpoch}',
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
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
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!email.contains('@')) {
        throw Exception('잘못된 이메일 형식입니다.');
      }
      if (password.length < 6) {
        throw Exception('비밀번호는 6자리 이하일 수 없습니다.');
      }
      if (nickname.isEmpty) {
        throw Exception('닉네임은 비어있을 수 없습니다.');
      }

      return UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        nickname: nickname,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      throw Exception('회원가입 오류: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser({required String token}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

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
