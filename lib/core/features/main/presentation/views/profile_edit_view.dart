import 'dart:io';

import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/app_snack_bar.dart';
import 'package:bumditbul_mobile/constants/app_icons.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:bumditbul_mobile/core/components/dialog/app_dialog.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/providers/auth_providers.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/widgets/school_search_sheet.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/providers/study_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditView extends ConsumerStatefulWidget {
  const ProfileEditView({super.key});

  @override
  ConsumerState<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends ConsumerState<ProfileEditView> {
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _schoolCtrl;
  bool _hasChanges = false;
  File? _selectedImage;

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _selectedImage = file;
      _hasChanges = true;
    });

    try {
      await ref.read(authStateProvider.notifier).uploadProfileImage(file);
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, '이미지 업로드에 실패했습니다.', isError: true);
      }
    }
  }

  Future<void> _pickSchool() async {
    final result = await showSchoolSearchSheet(context);
    if (result != null) {
      _schoolCtrl.text = result.name;
      if (result.nearestExamDate != null) {
        setExamDateOverride(ref, result.nearestExamDate!);
      }
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _save() async {
    final nickname = _nicknameCtrl.text.trim();
    if (nickname.isEmpty) return;

    try {
      await ref
          .read(authStateProvider.notifier)
          .updateProfile(
            nickname: nickname,
            school: _schoolCtrl.text.trim().isNotEmpty
                ? _schoolCtrl.text.trim()
                : null,
          );
      if (!mounted) return;
      setState(() => _hasChanges = false);
      showAppSnackBar(context, '프로필이 저장되었습니다.');
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, '저장에 실패했습니다.', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nicknameIsValid = _nicknameCtrl.text.trim().isNotEmpty;
    final profileImageUrl = ref.watch(authStateProvider).user?.profileImageUrl;

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
                      const Iconify(
                        Ic.round_arrow_back_ios,
                        color: BumditbulColor.white,
                        size: 20,
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
                      '닉네임과 프로필 사진, 학교명을 변경할 수 있어요.',
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
                          onTap: _pickImage,
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
                                clipBehavior: Clip.antiAlias,
                                child: _selectedImage != null
                                    ? Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      )
                                    : profileImageUrl != null
                                    ? Image.network(
                                        profileImageUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : const Iconify(
                                        Ic.round_person,
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
                                  child: const Iconify(
                                    AppIcons.cameraThin,
                                    color: BumditbulColor.white,
                                    size: 16,
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
                        hintText: '닉네임은 2~5자의 한글만 가능합니다.',
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
                      const SizedBox(height: 100),
                      DefaultButton(
                        onPressed: nicknameIsValid ? _save : null,
                        child: Text(
                          '저장',
                          style: BumditbulTextStyle.bodyLarge1.copyWith(
                            color: BumditbulColor.white,
                          ),
                        ),
                      ),
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
