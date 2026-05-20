import 'dart:async';

import 'package:bumditbul_mobile/constants/app_dimens.dart';
import 'package:bumditbul_mobile/constants/app_strings.dart';
import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/app_snack_bar.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:bumditbul_mobile/core/components/text_form_field/text_form_field.dart';
import 'package:bumditbul_mobile/core/components/text_form_field/text_form_field_label.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/providers/auth_providers.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:bumditbul_mobile/core/components/error_box.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/widgets/school_search_sheet.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/providers/study_provider.dart';
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

  late final TextEditingController _emailCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _passwordConfirmCtrl;
  final GlobalKey<FormState> _step1FormKey = GlobalKey();

  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _schoolCtrl;
  final GlobalKey<FormState> _step2FormKey = GlobalKey();

  bool _codeSent = false;
  bool _codeVerified = false;
  int _remainingSeconds = 180;
  Timer? _timer;

  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController()..addListener(_rebuild);
    _codeCtrl = TextEditingController()..addListener(_rebuild);
    _passwordCtrl = TextEditingController()..addListener(_rebuild);
    _passwordConfirmCtrl = TextEditingController()..addListener(_rebuild);
    _nicknameCtrl = TextEditingController()..addListener(_rebuild);
    _schoolCtrl = TextEditingController()..addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [
      _emailCtrl,
      _codeCtrl,
      _passwordCtrl,
      _passwordConfirmCtrl,
      _nicknameCtrl,
      _schoolCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _isStep1Valid =>
      _codeVerified &&
      _passwordCtrl.text.isNotEmpty &&
      _passwordConfirmCtrl.text.isNotEmpty;

  bool get _isStep2Valid => _nicknameCtrl.text.trim().isNotEmpty;

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 180;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        t.cancel();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String get _timerText {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@')) return;

    final isDuplicate = await ref
        .read(authStateProvider.notifier)
        .sendVerificationEmail(email: email);

    if (!mounted) return;
    if (isDuplicate) {
      _showSnack('이미 가입된 이메일입니다.', isError: true);
      return;
    }
    setState(() {
      _codeSent = true;
      _codeVerified = false;
    });
    _startTimer();
    _showSnack('인증번호가 발송되었습니다.');
  }

  Future<void> _verifyCode() async {
    final verified = await ref
        .read(authStateProvider.notifier)
        .verifyEmailCode(
          email: _emailCtrl.text.trim(),
          code: _codeCtrl.text.trim(),
        );
    if (mounted && verified) {
      setState(() => _codeVerified = true);
      _timer?.cancel();
      _showSnack('인증이 완료되었습니다.');
    }
  }

  InputDecoration _fieldDecoration({required String hintText, Widget? suffix, BoxConstraints? suffixConstraints}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle:
          BumditbulTextStyle.buttonMedium.copyWith(color: BumditbulColor.black700),
      suffixIcon: suffix,
      suffixIconConstraints: suffixConstraints,
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

    ref.listen<AuthState>(authStateProvider, (_, next) {
      if (next.isAuthenticated && !next.isLoading) {
        context.go(AppRoutes.subjectGrade, extra: _nicknameCtrl.text.trim());
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
                icon: const Iconify(Ic.round_arrow_back_ios, color: BumditbulColor.white, size: 20),
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
                child:
                    _step == 1 ? _buildStep1(authState) : _buildStep2(authState),
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

  Widget _buildStep1(AuthState authState) {
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
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: _codeSent && !_codeVerified == false,
                    decoration:
                        _fieldDecoration(hintText: AppStrings.hintEmail),
                    validator: (v) {
                      if (v == null || v.isEmpty) return AppStrings.errEmailEmpty;
                      if (!v.contains('@')) return AppStrings.errEmailInvalid;
                      return null;
                    },
                  ),
                ),
                AppDimens.gapH10,
                SizedBox(
                  width: 80,
                  height: 43,
                  child: ElevatedButton(
                    onPressed: _emailCtrl.text.isNotEmpty && !_codeVerified
                        ? _sendCode
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BumditbulColor.green600,
                      disabledBackgroundColor: BumditbulColor.black600,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimens.roundedS,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      _codeSent ? '재발송' : '인증',
                      style: BumditbulTextStyle.bodyMedium1
                          .copyWith(color: BumditbulColor.white),
                    ),
                  ),
                ),
              ],
            ),
            if (_codeSent) ...[
              AppDimens.gap20,
              CustomTextFormFieldLabel(labelText: AppStrings.labelCode),
              AppDimens.gap10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: _codeCtrl,
                      keyboardType: TextInputType.number,
                      readOnly: _codeVerified,
                      decoration: _fieldDecoration(
                        hintText: AppStrings.hintCode,
                        suffix: _codeVerified
                            ? const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.check_circle,
                                    color: BumditbulColor.green400, size: 20),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Text(
                                  _timerText,
                                  style: BumditbulTextStyle.bodyMedium1.copyWith(
                                    color: BumditbulColor.black400,
                                  ),
                                ),
                              ),
                        suffixConstraints:
                            const BoxConstraints(minHeight: 0, minWidth: 60),
                      ),
                    ),
                  ),
                  if (!_codeVerified) ...[
                    AppDimens.gapH10,
                    SizedBox(
                      width: 80,
                      height: 43,
                      child: ElevatedButton(
                        onPressed:
                            _codeCtrl.text.isNotEmpty ? _verifyCode : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BumditbulColor.green600,
                          disabledBackgroundColor: BumditbulColor.black600,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDimens.roundedS,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          '확인',
                          style: BumditbulTextStyle.bodyMedium1
                              .copyWith(color: BumditbulColor.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            AppDimens.gap20,
            CustomTextFormFieldLabel(labelText: AppStrings.labelPassword),
            AppDimens.gap10,
            CustomTextFormField(
              controller: _passwordCtrl,
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
              validator: (v) {
                if (v == null || v.isEmpty) return AppStrings.errPasswordEmpty;
                if (v.length < 8 ||
                    !v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                  return AppStrings.errPasswordInvalid;
                }
                return null;
              },
            ),
            AppDimens.gap20,
            CustomTextFormFieldLabel(labelText: AppStrings.labelPasswordConfirm),
            AppDimens.gap10,
            CustomTextFormField(
              controller: _passwordConfirmCtrl,
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
                  onPressed: () => setState(
                      () => _obscurePasswordConfirm = !_obscurePasswordConfirm),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return AppStrings.errPasswordConfirmEmpty;
                }
                if (v != _passwordCtrl.text) return AppStrings.errPasswordMismatch;
                return null;
              },
            ),
            if (authState.error != null && _step == 1) ...[
              AppDimens.gap16,
              ErrorBox(message: authState.error!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(AuthState authState) {
    return SingleChildScrollView(
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFormFieldLabel(labelText: AppStrings.labelNickname),
            AppDimens.gap10,
            CustomTextFormField(
              controller: _nicknameCtrl,
              decoration:
                  _fieldDecoration(hintText: AppStrings.hintNickname),
              maxLength: 8,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.errNicknameEmpty
                  : null,
            ),
            AppDimens.gap20,
            CustomTextFormFieldLabel(labelText: AppStrings.labelSchool),
            AppDimens.gap10,
            GestureDetector(
              onTap: () async {
                FocusScope.of(context).unfocus();
                final selected = await showSchoolSearchSheet(context);
                if (selected != null) {
                  _schoolCtrl.text = selected.name;
                  if (selected.nearestExamDate != null) {
                    setExamDateOverride(ref, selected.nearestExamDate!);
                  }
                  setState(() {});
                }
              },
              child: AbsorbPointer(
                child: CustomTextFormField(
                  controller: _schoolCtrl,
                  readOnly: true,
                  decoration: _fieldDecoration(
                    hintText: AppStrings.hintSchool,
                    suffix: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.search,
                          color: BumditbulColor.black400, size: 20),
                    ),
                  ),
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
              ErrorBox(message: authState.error!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(AuthState authState) {
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
                ref.read(authStateProvider.notifier).signup(
                      email: _emailCtrl.text.trim(),
                      password: _passwordCtrl.text,
                      nickname: _nicknameCtrl.text.trim(),
                      school: _schoolCtrl.text.trim().isNotEmpty
                          ? _schoolCtrl.text.trim()
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
                valueColor:
                    AlwaysStoppedAnimation<Color>(BumditbulColor.white),
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

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    showAppSnackBar(context, message, isError: isError);
  }
}
