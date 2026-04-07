import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:bumditbul_mobile/core/components/text_form_field/text_form_field.dart';
import 'package:bumditbul_mobile/core/components/text_form_field/text_form_field_label.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late GlobalKey<FormState> _formKey;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return '이메일을 입력해주세요';
    if (!value.contains('@')) return '⚠︎ 이메일 형식이 올바르지 않습니다.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return '비밀번호를 입력해주세요';
    if (value.length < 6) return '⚠︎ 비밀번호 형식이 올바르지 않습니다.';
    return null;
  }

  InputDecoration _fieldDecoration({required String hintText, Widget? suffix}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: BumditbulTextStyle.buttonLarge2.copyWith(
        color: BumditbulColor.black500,
      ),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: BumditbulColor.black600),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: BumditbulColor.black600),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: BumditbulColor.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (previous, next) {
      if (next.isAuthenticated && !next.isLoading) {
        context.go('/main');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              IconButton(
                onPressed: () => context.go('/'),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: BumditbulColor.white,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 24),
              Text(
                '로그인',
                style: BumditbulTextStyle.headline2.copyWith(
                  color: BumditbulColor.green600,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextFormFieldLabel(labelText: '이메일'),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _fieldDecoration(
                            hintText: '이메일을 입력해주세요.',
                          ),
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 24),
                        CustomTextFormFieldLabel(labelText: '비밀번호'),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _fieldDecoration(
                            hintText: '8자 이상 특수문자를 포함하여 입력해주세요.',
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: BumditbulColor.black400,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 24),
                        if (authState.error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: BumditbulColor.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              authState.error!,
                              style: BumditbulTextStyle.bodySmall.copyWith(
                                color: BumditbulColor.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              DefaultButton(
                onPressed: authState.isLoading || !_isFormValid
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          ref.read(authStateProvider.notifier).login(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                        }
                      },
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            BumditbulColor.white,
                          ),
                        ),
                      )
                    : Text(
                        '로그인',
                        style: BumditbulTextStyle.bodyLarge1.copyWith(
                          color: BumditbulColor.white,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
