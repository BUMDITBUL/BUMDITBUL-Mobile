import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:bumditbul_mobile/core/components/button/difficulty_dropdown.dart';
import 'package:flutter/material.dart';

class _EditEntry {
  final TextEditingController nameCtrl;
  String difficulty;

  _EditEntry({String name = '', this.difficulty = '중'})
    : nameCtrl = TextEditingController(text: name);

  void dispose() => nameCtrl.dispose();
}

class SubjectGradeEditView extends StatefulWidget {
  const SubjectGradeEditView({super.key});

  @override
  State<SubjectGradeEditView> createState() => _SubjectGradeEditViewState();
}

class _SubjectGradeEditViewState extends State<SubjectGradeEditView> {
  final List<_EditEntry> _entries = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _entries.addAll([
      _EditEntry(name: '수학', difficulty: '중'),
      _EditEntry(name: '영어', difficulty: '중'),
      _EditEntry(name: '과학', difficulty: '중'),
    ]);
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  Future<bool?> _showUnsavedDialog() {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: BumditbulColor.black800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: BumditbulColor.green400,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                '저장하지 않고 나가시겠어요?',
                style: BumditbulTextStyle.headline3.copyWith(
                  color: BumditbulColor.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '입력한 내용이 저장되지 않습니다.',
                textAlign: TextAlign.center,
                style: BumditbulTextStyle.bodyMedium1.copyWith(
                  color: BumditbulColor.black400,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: BumditbulColor.black600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        '취소',
                        style: BumditbulTextStyle.bodyLarge1.copyWith(
                          color: BumditbulColor.black400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BumditbulColor.green600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        '나가기',
                        style: BumditbulTextStyle.bodyLarge1.copyWith(
                          color: BumditbulColor.white,
                        ),
                      ),
                    ),
                  ),
                ],
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
              // ─ 헤더 ─
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
                    ..._entries.asMap().entries.map((e) {
                      final idx = e.key;
                      final entry = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: Key('edit_entry_$idx'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            setState(() {
                              _entries[idx].dispose();
                              _entries.removeAt(idx);
                              _hasChanges = true;
                            });
                          },
                          background: dismissBackground(
                            margin: EdgeInsets.zero,
                            borderRadius: 10,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: BumditbulColor.black800,
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
                        ),
                      );
                    }),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => setState(() {
                        _entries.add(_EditEntry());
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
                      onPressed: () {
                        setState(() => _hasChanges = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '성적이 저장되었습니다.',
                              style: BumditbulTextStyle.bodyMedium1,
                            ),
                            backgroundColor: BumditbulColor.green600,
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      child: Text(
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
