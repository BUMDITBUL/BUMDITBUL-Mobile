import 'dart:io';

import 'package:bumditbul_mobile/core/features/auth/data/models/token_model.dart';
import 'package:bumditbul_mobile/core/features/auth/data/models/user_model.dart';
import 'package:bumditbul_mobile/core/network/api_endpoint.dart';
import 'package:bumditbul_mobile/core/network/api_exception.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<bool> sendVerificationEmail({required String email});
  Future<bool> verifyEmailCode({required String email, required String code});
  Future<TokenModel> signup({required String email, required String password});
  Future<TokenModel> login({required String email, required String password});
  Future<void> logout({required String refreshToken});
  Future<String> refreshAccessToken({required String refreshToken});
  Future<void> withdraw();
  Future<TokenModel> loginWithGoogle({required String idToken});
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({required String nickname, String? school});
  Future<String> uploadProfileImage({required File image});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<bool> sendVerificationEmail({required String email}) async {
    try {
      final res = await dio.post(ApiEndpoint.emailSend, data: {'email': email});
      return res.data['isDuplicate'] as bool? ?? false;
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  @override
  Future<bool> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      final res = await dio.post(
        ApiEndpoint.emailVerify,
        data: {'email': email, 'code': code},
      );
      return res.data['verified'] as bool? ?? false;
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  @override
  Future<TokenModel> signup({
    required String email,
    required String password,
  }) async {
    try {
      final res = await dio.post(
        ApiEndpoint.signUp,
        data: {'email': email, 'password': password},
      );
      return TokenModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  @override
  Future<TokenModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await dio.post(
        ApiEndpoint.login,
        data: {'email': email, 'password': password},
      );
      return TokenModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    try {
      await dio.post(ApiEndpoint.logout, data: {'refreshToken': refreshToken});
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  @override
  Future<String> refreshAccessToken({required String refreshToken}) async {
    try {
      final res = await dio.post(
        ApiEndpoint.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      return res.data['accessToken'] as String;
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  @override
  Future<void> withdraw() async {
    try {
      await dio.delete(ApiEndpoint.withdraw);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  @override
  Future<TokenModel> loginWithGoogle({required String idToken}) async {
    try {
      final res = await dio.post(
        ApiEndpoint.googleOAuth,
        data: {'idToken': idToken},
      );
      return TokenModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final res = await dio.get(ApiEndpoint.profile);
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String nickname,
    String? school,
  }) async {
    try {
      final res = await dio.patch(
        ApiEndpoint.profile,
        data: {
          'nickname': nickname,
          if (school != null) 'school': school,
        },
      );
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  @override
  Future<String> uploadProfileImage({required File image}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      });
      final res = await dio.post(
        ApiEndpoint.profileImage,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return res.data['profileImageUrl'] as String;
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  ApiException _handle(DioException e) {
    final data = e.response?.data;
    final message = (data is Map ? data['message'] : null) as String? ??
        _defaultMessage(e.response?.statusCode);
    return ApiException(message, statusCode: e.response?.statusCode);
  }

  String _defaultMessage(int? status) => switch (status) {
        400 => '입력값을 확인해주세요.',
        401 => '이메일 또는 비밀번호가 올바르지 않습니다.',
        404 => '요청한 정보를 찾을 수 없습니다.',
        409 => '이미 가입된 이메일입니다.',
        _ => '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
      };
}
