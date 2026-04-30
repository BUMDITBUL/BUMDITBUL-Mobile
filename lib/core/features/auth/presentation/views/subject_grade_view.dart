import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:bumditbul_mobile/core/components/button/difficulty_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

int _nextId = 0;

Widget dismissBackground({
  required EdgeInsets margin,
  required double borderRadius,
}) {
  return Container(
    margin: margin,
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    child: const Icon(
      Icons.delete,
      color: Colors.white,
    ),
  );
}

class SubjectEntry {
  final int id;
  final TextEditingController nameController;
  String difficulty;

  SubjectEntry()
      : id = _nextId++,
        nameController = TextEditingController(),
        difficulty = '중';

  void dispose() => nameController.dispose();
}

final subjectEntriesProvider =
    StateNotifierProvider.autoDispose<SubjectEntriesNotifier, List<SubjectEntry>>(
  (ref) => SubjectEntriesNotifier(),
);

class SubjectEntriesNotifier extends StateNotifier<List<SubjectEntry>> {
  SubjectEntriesNotifier() : super([]);

  void add() {
    state = [...state, SubjectEntry()];
  }

  void remove(int index) {
    final entry = state[index];
    entry.dispose();
    final updated = List<SubjectEntry>.from(state)..removeAt(index);
    state = updated;
  }

  void setDifficulty(int index, String difficulty) {
    state[index].difficulty = difficulty;
    state = List<SubjectEntry>.from(state);
  }

  @override
  void dispose() {
    for (final e in state) {
      e.dispose();
    }
    super.dispose();
  }
}

class SubjectGradeView extends ConsumerStatefulWidget {
  final String userName;

  const SubjectGradeView({super.key, required this.userName});

  @override
  ConsumerState<SubjectGradeView> createState() => _SubjectGradeViewState();
}

class _SubjectGradeViewState extends ConsumerState<SubjectGradeView> {
  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectEntriesProvider);
    final notifier = ref.read(subjectEntriesProvider.notifier);
    final isComplete = subjects.isNotEmpty &&
        subjects.every((s) => s.nameController.text.trim().isNotEmpty);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.userName} 님의\n과목별 성적을 입력해주세요.',
                          style: BumditbulTextStyle.headline2.copyWith(
                            color: BumditbulColor.green400,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '왼쪽으로 밀면 과목을 삭제할 수 있습니다.',
                          style: BumditbulTextStyle.bodyMedium1.copyWith(
                            color: BumditbulColor.black500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      notifier.add();
                    },
                    child: const Icon(
                      Icons.add,
                      color: BumditbulColor.green400,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: subjects.isEmpty
                    ? const SizedBox()
                    : ListView.separated(
                        itemCount: subjects.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildSubjectItem(
                            context,
                            index,
                            subjects[index],
                            notifier,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              DefaultButton(
                onPressed: isComplete ? () => context.go('/main') : null,
                child: Text(
                  '완료',
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

  Widget _buildSubjectItem(
    BuildContext context,
    int index,
    SubjectEntry subject,
    SubjectEntriesNotifier notifier,
  ) {
    return Dismissible(
      key: Key('grade_entry_${subject.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        notifier.remove(index);
        setState(() {});
      },
      background: dismissBackground(
        margin: EdgeInsets.zero,
        borderRadius: 10,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: BumditbulColor.black850,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: BumditbulColor.black700, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 과목명 입력
            Expanded(
              child: TextField(
                controller: subject.nameController,
                onChanged: (_) => setState(() {}),
                style: BumditbulTextStyle.headline4.copyWith(
                  color: BumditbulColor.white,
                ),
                decoration: InputDecoration(
                  hintText: '과목명',
                  hintStyle: BumditbulTextStyle.headline4.copyWith(
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
            // 난이도 드롭다운
            DifficultyDropdown(
              value: subject.difficulty,
              width: 72,
              onChanged: (v) {
                notifier.setDifficulty(index, v);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
