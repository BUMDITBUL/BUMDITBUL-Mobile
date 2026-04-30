import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/button/difficulty_dropdown.dart';
import 'package:bumditbul_mobile/core/components/button/study_list_button.dart';
import 'package:bumditbul_mobile/core/components/modal/default_modal.dart';
import 'package:bumditbul_mobile/core/features/main/domain/entities/study_entities.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/providers/study_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudySubjectCard extends ConsumerWidget {
  final StudySubject subject;
  final DateTime date;

  const StudySubjectCard({
    super.key,
    required this.subject,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('subject_${subject.id}_${date.toIso8601String()}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) =>
          ref.read(studyProvider.notifier).removeSubject(date, subject.id),
      background: dismissBackground(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: BumditbulColor.black850,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BumditbulColor.black850, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(context, ref),
            if (subject.tasks.isNotEmpty) ...[
              const Divider(
                color: BumditbulColor.black850,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              _buildTaskList(ref),
            ],
            _buildAddTaskButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: BumditbulColor.green400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              subject.name,
              style: BumditbulTextStyle.headline4.copyWith(
                color: BumditbulColor.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: BumditbulColor.green600.withValues(alpha: 0.15),
              border: Border.all(
                color: BumditbulColor.green600,
                width: 1,
              ),
              shape: BoxShape.circle,
            ),
            child: Text(
              subject.difficulty,
              style: BumditbulTextStyle.bodySmall
            ),
          ),
          const SizedBox(width: 8),
          StudyListButton(
            isCompleted: subject.isAllCompleted,
            onTap: () {
              for (final task in subject.tasks) {
                if (task.isCompleted != !subject.isAllCompleted) {
                  ref
                      .read(studyProvider.notifier)
                      .toggleTask(date, subject.id, task.id);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Column(
        children: subject.tasks.map((task) {
          return _TaskItem(
            task: task,
            onToggle: () => ref
                .read(studyProvider.notifier)
                .toggleTask(date, subject.id, task.id),
            onDelete: () => ref
                .read(studyProvider.notifier)
                .removeTask(date, subject.id, task.id),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showAddTaskModal(context, ref),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        child: Row(
          children: [
            const Icon(Icons.add, color: BumditbulColor.black500, size: 16),
            const SizedBox(width: 6),
            Text(
              '할 일 추가',
              style: BumditbulTextStyle.bodyMedium1.copyWith(
                color: BumditbulColor.black500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskModal(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    DefaultModal.show(
      context,
      title: '${subject.name} 할 일 추가',
      confirmLabel: '추가',
      content: TextField(
        controller: controller,
        autofocus: true,
        style: BumditbulTextStyle.bodyLarge1.copyWith(
          color: BumditbulColor.white,
        ),
        decoration: InputDecoration(
          hintText: '할 일을 입력해주세요.',
          hintStyle: BumditbulTextStyle.bodyLarge1.copyWith(
            color: BumditbulColor.black600,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: BumditbulColor.black600),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: BumditbulColor.green400),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        cursorColor: BumditbulColor.green400,
      ),
      onConfirm: () {
        if (controller.text.trim().isNotEmpty) {
          ref
              .read(studyProvider.notifier)
              .addTask(date, subject.id, controller.text.trim());
          Navigator.of(context).pop();
        }
      },
    );
  }
}

class _TaskItem extends StatelessWidget {
  final StudyTask task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskItem({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              task.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              size: 18,
              color: task.isCompleted
                  ? BumditbulColor.green400
                  : BumditbulColor.black500,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onToggle,
              child: Text(
                task.description,
                style: BumditbulTextStyle.bodyMedium1.copyWith(
                  color: task.isCompleted
                      ? BumditbulColor.black500
                      : BumditbulColor.white,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: BumditbulColor.black500,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.close,
                size: 16,
                color: BumditbulColor.black600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
