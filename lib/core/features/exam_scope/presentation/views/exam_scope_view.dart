import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:bumditbul_mobile/core/components/button/difficulty_dropdown.dart';
import 'package:bumditbul_mobile/core/components/dialog/app_dialog.dart';
import 'package:bumditbul_mobile/core/features/exam_scope/presentation/widget/subject_card.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/widgets/exam_date_picker_sheet.dart';
import 'package:flutter/material.dart';

enum ExamMaterial { textbook, worksheet, workbook, custom }

extension ExamMaterialLabel on ExamMaterial {
  String get label {
    switch (this) {
      case ExamMaterial.textbook:
        return '교과서';
      case ExamMaterial.worksheet:
        return '학습지';
      case ExamMaterial.workbook:
        return '문제집';
      case ExamMaterial.custom:
        return '직접 입력';
    }
  }
}

class ExamRange {
  final ExamMaterial material;
  String startPage;
  String endPage;
  final TextEditingController customCtrl;

  ExamRange({
    required this.material,
    this.startPage = '',
    this.endPage = '',
  }) : customCtrl = TextEditingController();

  void dispose() => customCtrl.dispose();
}

class ExamSubjectEntry {
  final TextEditingController nameCtrl;
  String difficulty;
  DateTime? examDate;
  List<ExamRange> ranges;

  ExamSubjectEntry()
      : nameCtrl = TextEditingController(),
        difficulty = '중',
        ranges = [];

  void dispose() {
    nameCtrl.dispose();
    for (final r in ranges) {
      r.dispose();
    }
  }
}

class ExamScopeView extends StatefulWidget {
  const ExamScopeView({super.key});

  @override
  State<ExamScopeView> createState() => _ExamScopeViewState();
}

class _ExamScopeViewState extends State<ExamScopeView> {
  final List<ExamSubjectEntry> _subjects = [];
  bool _hasChanges = false;
  int _remainingGenerations = 2;
  static const int _maxGenerations = 2;

  @override
  void initState() {
    super.initState();
    _addSubject();
  }

  @override
  void dispose() {
    for (final s in _subjects) {
      s.dispose();
    }
    super.dispose();
  }

  void _addSubject() {
    setState(() {
      _subjects.add(ExamSubjectEntry());
      _hasChanges = true;
    });
  }

  void _removeSubject(int idx) {
    setState(() {
      _subjects[idx].dispose();
      _subjects.removeAt(idx);
      _hasChanges = true;
    });
  }

  void _toggleMaterial(int sIdx, ExamMaterial mat) {
    setState(() {
      final entry = _subjects[sIdx];
      final existing = entry.ranges.indexWhere((r) => r.material == mat);
      if (existing >= 0) {
        entry.ranges[existing].dispose();
        entry.ranges.removeAt(existing);
      } else {
        entry.ranges.add(ExamRange(material: mat));
      }
      _hasChanges = true;
    });
  }

  Future<bool?> _showUnsavedDialog() => AppDialog.showUnsaved(context);

  Future<bool?> _showSaveConfirmDialog() {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: BumditbulColor.popUp,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '시험 범위를 저장하시겠습니까?',
                textAlign: TextAlign.center,
                style: BumditbulTextStyle.headline3.copyWith(
                  color: BumditbulColor.white,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: BumditbulTextStyle.bodyMedium1.copyWith(
                    color: BumditbulColor.black400,
                  ),
                  children: [
                    const TextSpan(text: '저장된 범위를 바탕으로 학습 플랜이 재생성됩니다.\n오늘 재생성 남은 횟수: '),
                    TextSpan(
                      text: '$_remainingGenerations/$_maxGenerations회',
                      style: BumditbulTextStyle.bodyMedium1.copyWith(
                        color: BumditbulColor.green400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BumditbulColor.green600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  '저장하기',
                  style: BumditbulTextStyle.bodyLarge1.copyWith(
                    color: BumditbulColor.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: BumditbulColor.black600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  '취소',
                  style: BumditbulTextStyle.bodyLarge1.copyWith(
                    color: BumditbulColor.black400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      const Icon(Icons.chevron_left,
                          color: BumditbulColor.white, size: 22),
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
                      '시험범위를 입력해주세요.',
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
                          const TextSpan(text: '되며, 중요도는 자동으로 '),
                          TextSpan(
                            text: '중',
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
                    ..._subjects.asMap().entries.map(
                          (e) => Dismissible(
                            key: Key('exam_subject_${e.key}_${e.value.hashCode}'),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _removeSubject(e.key),
                            background: dismissBackground(
                              margin: const EdgeInsets.only(bottom: 12),
                              borderRadius: 12,
                            ),
                            child: SubjectCard(
                              entry: e.value,
                              index: e.key,
                              onRemove: () => _removeSubject(e.key),
                              onToggleMaterial: (mat) =>
                                  _toggleMaterial(e.key, mat),
                              onChanged: () =>
                                  setState(() => _hasChanges = true),
                              onDatePick: () async {
                                final picked = await showExamDatePickerSheet(
                                  context,
                                  initialDate: e.value.examDate,
                                );
                                if (picked != null) {
                                  setState(() {
                                    _subjects[e.key].examDate = picked;
                                    _hasChanges = true;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _addSubject,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: BumditbulColor.black700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_circle_outline,
                              color: BumditbulColor.black500,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '과목 추가하기',
                              style: BumditbulTextStyle.bodyLarge1.copyWith(
                                color: BumditbulColor.black500,
                              ),
                            ),
                          ],
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
                              const Icon(Icons.info_outline,
                                  color: BumditbulColor.green400, size: 16),
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
                            '언제든 시험범위를 수정할 수 있지만, 수정된 범위로 일정이 재생성됩니다.',
                            '시험 범위는 누락 없이 정확하게 기재해주세요.',
                            '입력된 데이터를 바탕으로 학습 플랜이 생성됩니다.',
                          ].map(
                            (t) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: BumditbulTextStyle.bodyMedium2
                                        .copyWith(
                                      color: BumditbulColor.black400,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      t,
                                      style: BumditbulTextStyle.bodyMedium2
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
                    const SizedBox(height: 24),
                    DefaultButton(
                      onPressed: _remainingGenerations > 0
                          ? () async {
                              final confirm = await _showSaveConfirmDialog();
                              if (!(confirm ?? false) || !context.mounted) return;
                              setState(() {
                                _hasChanges = false;
                                _remainingGenerations--;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '시험범위가 저장되었습니다.',
                                    style: BumditbulTextStyle.bodyMedium1,
                                  ),
                                  backgroundColor: BumditbulColor.green600,
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: Text(
                        _remainingGenerations > 0 ? '저장' : '오늘 저장 횟수 초과',
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
