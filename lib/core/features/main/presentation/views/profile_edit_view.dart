import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:bumditbul_mobile/core/components/dialog/app_dialog.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/providers/auth_providers.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/widgets/school_search_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileEditView extends ConsumerStatefulWidget {
  const ProfileEditView({super.key});

  @override
  ConsumerState<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends ConsumerState<ProfileEditView> {
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _schoolCtrl;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).user;
    _nicknameCtrl = TextEditingController(text: user?.nickname ?? '');
    _schoolCtrl = TextEditingController(text: user?.school ?? '');

    _nicknameCtrl.addListener(_onChanged);
    _schoolCtrl.addListener(_onChanged);
  }

  void _onChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _schoolCtrl.dispose();
    super.dispose();
  }

  Future<bool?> _showUnsavedDialog() => AppDialog.showUnsaved(context);

  Future<void> _handleBack() async {
    if (_hasChanges) {
      final leave = await _showUnsavedDialog();
      if ((leave ?? false) && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickSchool() async {
    final result = await showSchoolSearchSheet(context);
    if (result != null) {
      _schoolCtrl.text = result;
      setState(() => _hasChanges = true);
    }
  }

  void _save() {
    final nickname = _nicknameCtrl.text.trim();
    if (nickname.isEmpty) return;

    ref
        .read(authStateProvider.notifier)
        .updateProfile(
          nickname: nickname,
          school: _schoolCtrl.text.trim().isNotEmpty
              ? _schoolCtrl.text.trim()
              : null,
        );

    setState(() => _hasChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('프로필이 저장되었습니다.', style: BumditbulTextStyle.bodyMedium1),
        backgroundColor: BumditbulColor.green600,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final nicknameIsValid = _nicknameCtrl.text.trim().isNotEmpty;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final leave = await _showUnsavedDialog();
          if ((leave ?? false) && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: GestureDetector(
                  onTap: _handleBack,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chevron_left,
                        color: BumditbulColor.white,
                        size: 22,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '뒤로가기',
                        style: BumditbulTextStyle.bodyLarge1.copyWith(
                          color: BumditbulColor.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '프로필을 수정해주세요.',
                      style: BumditbulTextStyle.headline2.copyWith(
                        color: BumditbulColor.white,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '닉네임과 학교명을 변경할 수 있어요.',
                      style: BumditbulTextStyle.bodyMedium1.copyWith(
                        color: BumditbulColor.black400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: image picker
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: BumditbulColor.black700,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: BumditbulColor.black600,
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: BumditbulColor.black500,
                                  size: 48,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: BumditbulColor.green600,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: BumditbulColor.black850,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _FieldLabel(label: '닉네임', required: true),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _nicknameCtrl,
                        hintText: '닉네임을 입력해주세요.',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      _FieldLabel(label: '학교명', required: false),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickSchool,
                        child: AbsorbPointer(
                          child: _InputField(
                            controller: _schoolCtrl,
                            hintText: '학교명을 검색해주세요. (선택)',
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      DefaultButton(
                        onPressed: nicknameIsValid ? _save : null,
                        child: Text(
                          '저장',
                          style: BumditbulTextStyle.bodyLarge1.copyWith(
                            color: BumditbulColor.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: BumditbulColor.black700, height: 1),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _FieldLabel({required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: BumditbulTextStyle.bodyLarge2.copyWith(
            color: BumditbulColor.white,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: BumditbulTextStyle.bodyLarge2.copyWith(
              color: BumditbulColor.green400,
            ),
          ),
        ],
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final void Function(String) onChanged;

  const _InputField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BumditbulColor.black850,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: BumditbulColor.black700, width: 0.5),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: BumditbulTextStyle.bodyLarge2.copyWith(
          color: BumditbulColor.white,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: BumditbulTextStyle.bodyLarge2.copyWith(
            color: BumditbulColor.black600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
        cursorColor: BumditbulColor.green400,
      ),
    );
  }
}
