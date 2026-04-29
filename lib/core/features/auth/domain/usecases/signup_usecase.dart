import 'package:bumditbul_mobile/core/features/auth/domain/entities/user_entity.dart';
import 'package:bumditbul_mobile/core/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class SignupUseCase {
  final AuthRepository authRepository;

  SignupUseCase(this.authRepository);

  Future<User> call(SignupParams params) async {
    return await authRepository.signup(
      email: params.email,
      password: params.password,
      nickname: params.nickname,
    );
  }
}

class SignupParams extends Equatable {
  final String email;
  final String password;
  final String nickname;

  const SignupParams({
    required this.email,
    required this.password,
    required this.nickname,
  });

  @override
  List<Object?> get props => [email, password, nickname];
}
