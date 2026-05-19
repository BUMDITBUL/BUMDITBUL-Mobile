import 'package:bumditbul_mobile/core/features/auth/domain/entities/user_entity.dart';
import 'package:bumditbul_mobile/core/features/auth/domain/repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository authRepository;

  SignupUseCase(this.authRepository);

  Future<User> call({
    required String email,
    required String password,
    required String nickname,
    String? school,
  }) =>
      authRepository.signup(
        email: email,
        password: password,
        nickname: nickname,
        school: school,
      );
}
