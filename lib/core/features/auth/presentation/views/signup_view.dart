import 'dart:async';

import 'package:bumditbul_mobile/constants/app_dimens.dart';
import 'package:bumditbul_mobile/constants/app_strings.dart';
import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:bumditbul_mobile/core/components/text_form_field/text_form_field.dart';
import 'package:bumditbul_mobile/core/components/text_form_field/text_form_field_label.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/providers/auth_providers.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/widgets/school_search_sheet.dart';
import 'package:bumditbul_mobile/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  int _step = 1;

  late TextEditingController _emailController;
  late TextEditingController _verificationCodeController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmController;
  late GlobalKey<FormState> _step1FormKey;

  late TextEditingController _nicknameController;
  late TextEditingController _schoolController;
  late GlobalKey<FormState> _step2FormKey;

  Timer? _timer;
  int _remainingSeconds = 180;
  bool _isCodeSent = false;

  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _verificationCodeController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();
    _nicknameController = TextEditingController();
    _schoolController = TextEditingController();
    _step1FormKey = GlobalKey<FormState>();
    _step2FormKey = GlobalKey<FormState>();

    _emailController.addListener(_onFieldChanged);
    _verificationCodeController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _passwordConfirmController.addListener(_onFieldChanged);
    _nicknameController.addListener(_onFieldChanged);
    _schoolController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _verificationCodeController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nicknameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  bool get _isStep1Valid =>
      _emailController.text.isNotEmpty &&
      _verificationCodeController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _passwordConfirmController.text.isNotEmpty;

  bool get _isStep2Valid => _nicknameController.text.isNotEmpty;

  void _sendVerificationCode() {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      return;
    }
    setState(() {
      _isCodeSent = true;
      _remainingSeconds = 180;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String get _timerText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return AppStrings.errEmailEmpty;
    if (!value.contains('@')) return AppStrings.errEmailInvalid;
    return null;
  }

  String? _validateCode(String? value) {
    if (value == null || value.isEmpty) return AppStrings.errCodeEmpty;
    if (value.length < 6) return AppStrings.errCodeInvalid;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return AppStrings.errPasswordEmpty;
    if (value.length < 8 ||
        !value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return AppStrings.errPasswordInvalid;
    }
    return null;
  }

  String? _validatePasswordConfirm(String? value) {
    if (value == null || value.isEmpty) return AppStrings.errPasswordConfirmEmpty;
    if (value != _passwordController.text) return AppStrings.errPasswordMismatch;
    return null;
  }

  String? _validateNickname(String? value) {
    if (value == null || value.isEmpty) return AppStrings.errNicknameEmpty;
    return null;
  }

  String? _validateSchoolName(String? value) {
    if (value == null || value.isEmpty) return AppStrings.errSchoolEmpty;
    return null;
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    Widget? suffix,
    BoxConstraints? suffixConstraints,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: BumditbulTextStyle.buttonMedium
          .copyWith(color: BumditbulColor.black700),
      suffixIcon: suffix,
      suffixIconConstraints: suffixConstraints,
      border: OutlineInputBorder(
          borderRadius: AppDimens.roundedS,
          borderSide: const BorderSide(color: BumditbulColor.black600)),
      enabledBorder: OutlineInputBorder(
          borderRadius: AppDimens.roundedS,
          borderSide: const BorderSide(color: BumditbulColor.black600)),
      focusedBorder: OutlineInputBorder(
          borderRadius: AppDimens.roundedS,
          borderSide: const BorderSide(color: BumditbulColor.green400)),
      errorBorder: OutlineInputBorder(
          borderRadius: AppDimens.roundedS,
          borderSide: const BorderSide(color: BumditbulColor.red)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimens.roundedS,
          borderSide: const BorderSide(color: BumditbulColor.red)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (previous, next) {
      if (next.isAuthenticated && !next.isLoading) {
        if (context.mounted) {
          context.go(AppRoutes.subjectGrade, extra: _nicknameController.text);
        }
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
                onPressed: () {
                  if (_step == 2) {
                    setState(() => _step = 1);
                  } else {
                    context.go(AppRoutes.splash);
                  }
                },
                icon: const Icon(Icons.arrow_back_ios,
                    color: BumditbulColor.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              AppDimens.gap24,
              Text(
                '회원가입',
                style: BumditbulTextStyle.headline2.copyWith(
                  color: BumditbulColor.green600,
                  fontSize: 22,
                ),
              ),
              AppDimens.gap40,
              Expanded(
                child: _step == 1 ? _buildStep1() : _buildStep2(authState),
              ),
              AppDimens.gap20,
              _buildBottomButton(authState),
              AppDimens.gap24,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFormFieldLabel(labelText: AppStrings.labelEmail),
            AppDimens.gap10,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _fieldDecoration(hintText: AppStrings.hintEmail),
                    validator: _validateEmail,
                  ),
                ),
                AppDimens.gapH10,
                SizedBox(
                  width: 80,
                  height: 43,
                  child: ElevatedButton(
                    onPressed: _emailController.text.isNotEmpty
                        ? _sendVerificationCode
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _emailController.text.isNotEmpty
                          ? BumditbulColor.green600
                          : BumditbulColor.black600,
                      disabledBackgroundColor: BumditbulColor.black600,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppDimens.roundedS),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      AppStrings.labelCode,
                      style: BumditbulTextStyle.bodyMedium1
                          .copyWith(color: BumditbulColor.white),
                    ),
                  ),
                ),
              ],
            ),
            AppDimens.gap20,
            CustomTextFormFieldLabel(labelText: AppStrings.labelCode),
            AppDimens.gap10,
            CustomTextFormField(
              controller: _verificationCodeController,
              keyboardType: TextInputType.number,
              readOnly: !_isCodeSent,
              decoration: _fieldDecoration(
                hintText: AppStrings.hintCode,
                suffix: _isCodeSent
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          _timerText,
                          style: BumditbulTextStyle.bodyMedium1.copyWith(
                            color: BumditbulColor.black400,
                          ),
                        ),
                      )
                    : null,
                suffixConstraints: const BoxConstraints(
                  minHeight: 0,
                  minWidth: 60,
                ),
              ),
              validator: _isCodeSent ? _validateCode : null,
            ),
            AppDimens.gap20,
            CustomTextFormFieldLabel(labelText: AppStrings.labelPassword),
            AppDimens.gap10,
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
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: _validatePassword,
            ),
            AppDimens.gap20,
            CustomTextFormFieldLabel(
                labelText: AppStrings.labelPasswordConfirm),
            AppDimens.gap10,
            CustomTextFormField(
              controller: _passwordConfirmController,
              obscureText: _obscurePasswordConfirm,
              decoration: _fieldDecoration(
                hintText: AppStrings.hintPassword,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePasswordConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: BumditbulColor.black400,
                    size: 20,
                  ),
                  onPressed: () => setState(() =>
                      _obscurePasswordConfirm = !_obscurePasswordConfirm),
                ),
              ),
              validator: _validatePasswordConfirm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(dynamic authState) {
    return SingleChildScrollView(
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFormFieldLabel(labelText: AppStrings.labelNickname),
            AppDimens.gap10,
            CustomTextFormField(
              controller: _nicknameController,
              decoration: _fieldDecoration(hintText: AppStrings.hintNickname),
              validator: _validateNickname,
              maxLength: 8,
            ),
            if (authState.error != null) ...[
              AppDimens.gap16,
              _ErrorBox(message: authState.error!),
            ],
            AppDimens.gap20,
            CustomTextFormFieldLabel(labelText: AppStrings.labelSchool),
            AppDimens.gap10,
            GestureDetector(
              onTap: () async {
                FocusScope.of(context).unfocus();
                final selected = await showSchoolSearchSheet(context);
                if (selected != null) {
                  _schoolController.text = selected;
                  setState(() {});
                }
              },
              child: AbsorbPointer(
                child: CustomTextFormField(
                  controller: _schoolController,
                  readOnly: true,
                  decoration: _fieldDecoration(
                    hintText: AppStrings.hintSchool,
                    suffix: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.search,
                          color: BumditbulColor.black400, size: 20),
                    ),
                  ),
                  validator: _validateSchoolName,
                ),
              ),
            ),
            AppDimens.gap6,
            RichText(
              text: TextSpan(
                style: BumditbulTextStyle.buttonMedium
                    .copyWith(color: BumditbulColor.black500),
                children: const [
                  TextSpan(text: '시험 당일 응원해드려요. '),
                  TextSpan(
                    text: '(필수X)',
                    style: TextStyle(color: BumditbulColor.green400),
                  ),
                ],
              ),
            ),
            if (authState.error != null) ...[
              AppDimens.gap16,
              _ErrorBox(message: authState.error!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(dynamic authState) {
    if (_step == 1) {
      return DefaultButton(
        onPressed: _isStep1Valid
            ? () {
                if (_step1FormKey.currentState!.validate()) {
                  setState(() => _step = 2);
                }
              }
            : null,
        child: Text(
          '다음',
          style: BumditbulTextStyle.bodyLarge1.copyWith(
            color: BumditbulColor.white,
          ),
        ),
      );
    }

    return DefaultButton(
      onPressed: authState.isLoading || !_isStep2Valid
          ? null
          : () {
              if (_step2FormKey.currentState!.validate()) {
                ref
                    .read(authStateProvider.notifier)
                    .signup(
                      email: _emailController.text,
                      password: _passwordController.text,
                      nickname: _nicknameController.text,
                      school: _schoolController.text.isNotEmpty
                          ? _schoolController.text
                          : null,
                    );
              }
            },
      child: authState.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(BumditbulColor.white),
              ),
            )
          : Text(
              '회원가입',
              style: BumditbulTextStyle.bodyLarge1.copyWith(
                color: BumditbulColor.white,
              ),
            ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;

  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BumditbulColor.red.withValues(alpha: 0.1),
        borderRadius: AppDimens.roundedS,
        border: Border.all(color: BumditbulColor.red),
      ),
      child: Text(
        message,
        style: BumditbulTextStyle.bodyMedium1.copyWith(
          color: BumditbulColor.red,
        ),
      ),
    );
  }
}