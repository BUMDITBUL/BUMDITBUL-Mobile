import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class SplashView extends ConsumerWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    onPressed: () => context.go('/login'),
                    backgroundColor: BumditbulColor.green400,
                    child: const Text('로그인'),
                  ),
                  const SizedBox(height: 20),
                  DefaultButton(
                    onPressed: () => context.go('/signup'),
                    backgroundColor: BumditbulColor.black900,
                    borderSide: const BorderSide(
                      color: BumditbulColor.black600,
                      width: 1,
                    ),
                    child: const Text('회원가입'),
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
}
