import 'package:bumditbul_mobile/core/features/auth/domain/entities/user_entity.dart';
import 'package:bumditbul_mobile/core/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  Future<User> call(LoginParams params) async {
    return await authRepository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
