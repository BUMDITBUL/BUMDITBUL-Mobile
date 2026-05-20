import 'package:bumditbul_mobile/constants/app_dimens.dart';
import 'package:bumditbul_mobile/constants/app_strings.dart';
import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:bumditbul_mobile/core/components/error_box.dart';
import 'package:bumditbul_mobile/core/components/text_form_field/text_form_field.dart';
import 'package:bumditbul_mobile/core/components/text_form_field/text_form_field_label.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/providers/auth_providers.dart';
import 'package:bumditbul_mobile/core/features/schedule/presentation/providers/schedule_providers.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:bumditbul_mobile/core/router/app_routes.dart';
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
    if (value == null || value.isEmpty) return AppStrings.errEmailEmpty;
    if (!value.contains('@')) return AppStrings.errEmailInvalid;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return AppStrings.errPasswordEmpty;
    if (value.length < 6) return AppStrings.errPasswordInvalid;
    return null;
  }

  InputDecoration _fieldDecoration({required String hintText, Widget? suffix}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: BumditbulTextStyle.buttonLarge2
          .copyWith(color: BumditbulColor.black500),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: AppDimens.roundedS,
        borderSide: const BorderSide(color: BumditbulColor.black600),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppDimens.roundedS,
        borderSide: const BorderSide(color: BumditbulColor.black600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppDimens.roundedS,
        borderSide: const BorderSide(color: BumditbulColor.green400),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppDimens.roundedS,
        borderSide: const BorderSide(color: BumditbulColor.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppDimens.roundedS,
        borderSide: const BorderSide(color: BumditbulColor.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (previous, next) {
      if (next.isAuthenticated && !next.isLoading) {
        ref.read(dailyPlanProvider.notifier).fetch();
        ref.read(subjectProvider.notifier).fetch();
        context.go(AppRoutes.main);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppDimens.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDimens.gap8,
              IconButton(
                onPressed: () => context.go(AppRoutes.splash),
                icon: const Iconify(Ic.round_arrow_back_ios,
                    color: BumditbulColor.white, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              AppDimens.gap24,
              Text(
                '로그인',
                style: BumditbulTextStyle.headline2.copyWith(
                  color: BumditbulColor.green600,
                  fontSize: 22,
                ),
              ),
              AppDimens.gap40,
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextFormFieldLabel(
                            labelText: AppStrings.labelEmail),
                        AppDimens.gap8,
                        CustomTextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _fieldDecoration(
                              hintText: AppStrings.hintEmail),
                          validator: _validateEmail,
                        ),
                        AppDimens.gap24,
                        CustomTextFormFieldLabel(
                            labelText: AppStrings.labelPassword),
                        AppDimens.gap8,
                        CustomTextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _fieldDecoration(
                            hintText: AppStrings.hintPassword,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: BumditbulColor.black400,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: _validatePassword,
                        ),
                        if (authState.error != null) ...[
                          AppDimens.gap24,
                          ErrorBox(message: authState.error!),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              AppDimens.gap24,
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
                              BumditbulColor.white),
                        ),
                      )
                    : Text(
                        '로그인',
                        style: BumditbulTextStyle.bodyLarge1
                            .copyWith(color: BumditbulColor.white),
                      ),
              ),
              AppDimens.gap24,
            ],
          ),
        ),
      ),
    );
  }
}

