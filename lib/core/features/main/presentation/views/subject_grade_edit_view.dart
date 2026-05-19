import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/app_snack_bar.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:bumditbul_mobile/core/components/button/difficulty_dropdown.dart';
import 'package:bumditbul_mobile/core/components/dialog/app_dialog.dart';
import 'package:bumditbul_mobile/core/features/schedule/presentation/providers/schedule_providers.dart';
import 'package:bumditbul_mobile/core/features/subject/domain/entities/subject_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

int _editEntryIdCounter = 0;

String _apiToKorean(String api) => switch (api.toUpperCase()) {
  'HIGH' => '상',
  'LOW' => '하',
  _ => '중',
};

String _koreanToApi(String korean) => switch (korean) {
  '상' => 'HIGH',
  '하' => 'LOW',
  _ => 'MEDIUM',
};

class _EditEntry {
  final int id;
  final TextEditingController nameCtrl;
  String difficulty;

  _EditEntry({String name = '', this.difficulty = '중'})
    : id = _editEntryIdCounter++,
      nameCtrl = TextEditingController(text: name);

  void dispose() => nameCtrl.dispose();
}

class SubjectGradeEditView extends ConsumerStatefulWidget {
  const SubjectGradeEditView({super.key});

  @override
  ConsumerState<SubjectGradeEditView> createState() =>
      _SubjectGradeEditViewState();
}

class _SubjectGradeEditViewState extends ConsumerState<SubjectGradeEditView> {
  List<_EditEntry>? _entries;
  bool _hasChanges = false;

  void _initEntriesIfNeeded(List subjects) {
    if (_entries != null) return;
    setState(() {
      _entries = subjects
          .map((s) => _EditEntry(
                name: s.subjectName,
                difficulty: _apiToKorean(s.difficulty),
              ))
          .toList();
    });
  }

  @override
  void dispose() {
    for (final e in _entries ?? []) {
      e.dispose();
    }
    super.dispose();
  }

  Future<bool?> _showUnsavedDialog() => AppDialog.showUnsaved(context);

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectProvider);
    subjectsAsync.whenOrNull(
      data: (subjects) => _initEntriesIfNeeded(subjects),
    );

    if (_entries == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: BumditbulColor.green400),
        ),
      );
    }

    final entries = _entries!;

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
                  onTap: () async {
                    if (_hasChanges) {
                      final leave = await _showUnsavedDialog();
                      if ((leave ?? false) && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chevron_left,
                        color: BumditbulColor.white,
                        size: 22,
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
                      '과목별 성적을 수정해주세요.',
                      style: BumditbulTextStyle.headline2.copyWith(
                        color: BumditbulColor.white,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: BumditbulTextStyle.bodyMedium1.copyWith(
                          color: BumditbulColor.black400,
                        ),
                        children: [
                          const TextSpan(text: '입력하지 않은 과목은 '),
                          TextSpan(
                            text: '제외',
                            style: BumditbulTextStyle.bodyMedium1.copyWith(
                              color: BumditbulColor.green400,
                            ),
                          ),
                          const TextSpan(text: '되며, 성적은 '),
                          TextSpan(
                            text: '자동으로 중',
                            style: BumditbulTextStyle.bodyMedium1.copyWith(
                              color: BumditbulColor.green400,
                            ),
                          ),
                          const TextSpan(text: '으로 설정됩니다.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '왼쪽으로 밀면 과목을 삭제할 수 있습니다.',
                      style: BumditbulTextStyle.bodyMedium2.copyWith(
                        color: BumditbulColor.black600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    ...entries.map((entry) {
                      return Dismissible(
                        key: Key('edit_entry_${entry.id}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          setState(() {
                            entry.dispose();
                            _entries!.remove(entry);
                            _hasChanges = true;
                          });
                        },
                        background: dismissBackground(
                          margin: const EdgeInsets.only(bottom: 10),
                          borderRadius: 10,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: BumditbulColor.black850,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: BumditbulColor.black700,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: entry.nameCtrl,
                                  onChanged: (_) =>
                                      setState(() => _hasChanges = true),
                                  style: BumditbulTextStyle.headline4
                                      .copyWith(color: BumditbulColor.white),
                                  decoration: InputDecoration(
                                    hintText: '과목명',
                                    hintStyle: BumditbulTextStyle.headline4
                                        .copyWith(
                                          color: BumditbulColor.black600,
                                        ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  cursorColor: BumditbulColor.green400,
                                ),
                              ),
                              const SizedBox(width: 12),
                              DifficultyDropdown(
                                value: entry.difficulty,
                                width: 72,
                                onChanged: (v) => setState(() {
                                  entry.difficulty = v;
                                  _hasChanges = true;
                                }),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => setState(() {
                        _entries!.add(_EditEntry());
                        _hasChanges = true;
                      }),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: BumditbulColor.green600,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '추가하기 +',
                          style: BumditbulTextStyle.bodyLarge2.copyWith(
                            color: BumditbulColor.green400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: BumditbulColor.green600.withValues(alpha: 0.08),
                        border: Border.all(
                          color: BumditbulColor.green600.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: BumditbulColor.green400,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '알림 사항',
                                style: BumditbulTextStyle.headline5.copyWith(
                                  color: BumditbulColor.green400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...[
                            '언제든 다시 수정할 수 있지만,\n수정된 성적으로 플랜이 재생성됩니다.',
                            '성적은 누락 없이 정확하게 기재해주세요.',
                            '입력된 데이터를 바탕으로 학습 플랜이 생성됩니다.',
                          ].map(
                            (t) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: BumditbulTextStyle.bodyMedium1
                                        .copyWith(
                                          color: BumditbulColor.black400,
                                        ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      t,
                                      style: BumditbulTextStyle.bodyMedium1
                                          .copyWith(
                                            color: BumditbulColor.black400,
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
                    const SizedBox(height: 16),
                    Text(
                      '일정 생성에 반영되는 만큼 정확하게 입력해주세요.\n기본과목은 선택하지 않으면 자동으로 미입력 처리됩니다.',
                      style: BumditbulTextStyle.bodyMedium2.copyWith(
                        color: BumditbulColor.black500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DefaultButton(
                      onPressed: ref.watch(subjectProvider).isLoading
                          ? null
                          : () async {
                              final existingSubjects =
                                  ref.read(subjectProvider).valueOrNull ?? [];
                              final subjectMap = {
                                for (final s in existingSubjects)
                                  s.subjectName: s,
                              };
                              final fallbackSchedule =
                                  existingSubjects.firstOrNull?.testSchedule ?? '';
                              final inputs = entries
                                  .where((e) => e.nameCtrl.text.trim().isNotEmpty)
                                  .map((e) {
                                final name = e.nameCtrl.text.trim();
                                final matched = subjectMap[name];
                                return SubjectInput(
                                  subjectName: name,
                                  startPage: matched?.startPage ?? 1,
                                  endPage: matched?.endPage ?? 1,
                                  difficulty: _koreanToApi(e.difficulty),
                                  testSchedule:
                                      matched?.testSchedule ?? fallbackSchedule,
                                );
                              }).toList();
                              try {
                                await ref
                                    .read(subjectProvider.notifier)
                                    .saveAndGenerate(inputs);
                                if (!context.mounted) return;
                                setState(() => _hasChanges = false);
                                showAppSnackBar(context, '성적이 저장되었습니다.');
                                Navigator.of(context).pop();
                              } catch (_) {
                                if (context.mounted) {
                                  showAppSnackBar(
                                    context,
                                    '저장에 실패했습니다.',
                                    isError: true,
                                  );
                                }
                              }
                            },
                      child: ref.watch(subjectProvider).isLoading
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
                              '저장',
                              style: BumditbulTextStyle.bodyLarge1.copyWith(
                                color: BumditbulColor.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
