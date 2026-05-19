import 'package:bumditbul_mobile/core/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bumditbul_mobile/core/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bumditbul_mobile/core/features/auth/domain/repositories/auth_repository.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:bumditbul_mobile/core/network/dio_client.dart';
import 'package:bumditbul_mobile/core/services/token_storage.dart';
import 'package:bumditbul_mobile/core/services/user_prefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final userPrefsProvider = Provider<UserPrefs>((ref) => UserPrefs());

final dioClientProvider = Provider<DioClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return DioClient(tokenStorage);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return AuthRemoteDataSourceImpl(client.dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
    userPrefs: ref.watch(userPrefsProvider),
  );
});

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(
    repo: ref.watch(authRepositoryProvider),
    userPrefs: ref.watch(userPrefsProvider),
  );
});
