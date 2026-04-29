import 'package:bumditbul_mobile/core/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bumditbul_mobile/core/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bumditbul_mobile/core/features/auth/domain/repositories/auth_repository.dart';
import 'package:bumditbul_mobile/core/features/auth/domain/usecases/login_usecase.dart';
import 'package:bumditbul_mobile/core/features/auth/domain/usecases/signup_usecase.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider((ref) => Dio());

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDataSourceImpl(dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

final loginUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final signupUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignupUseCase(repository);
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final signupUseCase = ref.watch(signupUseCaseProvider);

  return AuthStateNotifier(
    loginUseCase: loginUseCase,
    signupUseCase: signupUseCase,
  );
});
