import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/app_snack_bar.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:bumditbul_mobile/core/config/google_sign_in_config.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/providers/auth_providers.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:bumditbul_mobile/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _googleSignIn = GoogleSignIn(
  serverClientId: GoogleSignInConfig.serverClientId,
  scopes: ['email', 'profile'],
);

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (_, next) {
      if (next.isAuthenticated && !next.isLoading) {
        if (next.isNewUser) {
          context.go(AppRoutes.subjectGrade, extra: next.user?.nickname ?? '');
        } else {
          context.go(AppRoutes.main);
        }
      }
    });

    if (authState.isLoading || authState.isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: Image(
            image: AssetImage('assets/images/app_logo.png'),
            width: 200,
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Image.asset('assets/images/app_logo.png', width: 200),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  DefaultButton(
                    onPressed: () => context.go(AppRoutes.login),
                    backgroundColor: BumditbulColor.green400,
                    child: const Text('로그인'),
                  ),
                  const SizedBox(height: 20),
                  DefaultButton(
                    onPressed: () => context.go(AppRoutes.signup),
                    backgroundColor: BumditbulColor.black900,
                    borderSide: const BorderSide(
                      color: BumditbulColor.black600,
                      width: 1,
                    ),
                    child: const Text('회원가입'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '또는',
                    style: BumditbulTextStyle.buttonLarge2.copyWith(
                      color: BumditbulColor.black600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            side: const BorderSide(
                              color: BumditbulColor.black600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          onPressed:
                              _isGoogleLoading ? null : _handleGoogleLogin,
                          child: _isGoogleLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      BumditbulColor.green400,
                                    ),
                                  ),
                                )
                              : SvgPicture.asset(
                                  'assets/images/google.svg',
                                  width: 24,
                                  height: 24,
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return; // 사용자가 취소

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        _showError('Google 인증 토큰을 가져올 수 없습니다.');
        return;
      }

      await ref.read(authStateProvider.notifier).loginWithGoogle(
            idToken: idToken,
            email: account.email,
            displayName: account.displayName,
          );

      final state = ref.read(authStateProvider);
      if (state.error != null && mounted) {
        _showError(state.error!);
      }
    } catch (e) {
      if (mounted) _showError('Google 로그인 중 오류가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showAppSnackBar(context, message, isError: true);
  }
}
