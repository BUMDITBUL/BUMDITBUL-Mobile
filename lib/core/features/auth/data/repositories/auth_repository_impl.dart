import 'package:bumditbul_mobile/core/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bumditbul_mobile/core/features/auth/domain/entities/user_entity.dart';
import 'package:bumditbul_mobile/core/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  String? _cachedToken;
  User? _cachedUser;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      _cachedToken = userModel.token;
      _cachedUser = userModel;

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> signup({
    required String email,
    required String password,
    required String nickname,
    String? school,
  }) async {
    try {
      final userModel = await remoteDataSource.signup(
        email: email,
        password: password,
        nickname: nickname,
        school: school,
      );

      _cachedToken = userModel.token;
      _cachedUser = userModel;

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      if (_cachedUser != null && _cachedToken != null && _cachedToken!.isNotEmpty) {
        return _cachedUser;
      }

      if (_cachedToken != null && _cachedToken!.isNotEmpty) {
        final userModel = await remoteDataSource.getCurrentUser(
          token: _cachedToken!,
        );
        _cachedUser = userModel;
        return userModel;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      _cachedToken = null;
      _cachedUser = null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isTokenValid() async {
    return _cachedToken != null && _cachedToken!.isNotEmpty;
  }
}
