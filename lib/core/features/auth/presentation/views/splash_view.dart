import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class SplashView extends ConsumerWidget {
  static const h20 = SizedBox(height: 20);

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
                  h20,
                  DefaultButton(
                    onPressed: () => context.go('/signup'),
                    backgroundColor: BumditbulColor.black900,
                    borderSide: const BorderSide(
                      color: BumditbulColor.black600,
                      width: 1,
                    ),
                    child: const Text('회원가입'),
                  ),
                  h20,
                  Text(
                    '또는',
                    style: BumditbulTextStyle.buttonLarge2.copyWith(
                      color: BumditbulColor.black600,
                    ),
                  ),
                  h20,
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
                          ),
                          onPressed: () {},
                          child: SvgPicture.asset(
                            'assets/images/google.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {},
                          child: SvgPicture.asset(
                            'assets/images/apple.svg',
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
}
