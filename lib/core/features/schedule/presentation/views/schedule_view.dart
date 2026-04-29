import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/features/main/domain/entities/study_entities.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/providers/study_provider.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/widgets/month_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleView extends ConsumerWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final studyState = ref.watch(studyProvider);
    final subjects = studyState.getSubjectsForDate(selectedDate);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '일정',
                style: BumditbulTextStyle.headline2.copyWith(fontSize: 20),
              ),
            ),
            const MonthCalendar(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    _formatDate(selectedDate),
                    style: BumditbulTextStyle.headline4.copyWith(
                      color: BumditbulColor.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: BumditbulColor.green600.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${subjects.length}개 과목',
                      style: BumditbulTextStyle.bodyMedium2.copyWith(
                        color: BumditbulColor.green400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: subjects.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: subjects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _ScheduleSubjectTile(subject: subjects[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.month}월 ${date.day}일 ($weekday)';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_note_outlined,
            color: BumditbulColor.black700,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            '이 날은 공부 계획이 없어요.',
            style: BumditbulTextStyle.bodyLarge1.copyWith(
              color: BumditbulColor.black500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '홈에서 공부 계획을 추가해보세요!',
            style: BumditbulTextStyle.bodyMedium1.copyWith(
              color: BumditbulColor.black600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleSubjectTile extends StatelessWidget {
  final StudySubject subject;

  const _ScheduleSubjectTile({required this.subject});

  @override
  Widget build(BuildContext context) {
    final total = subject.tasks.length;
    final completed = subject.completedCount;
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BumditbulColor.black800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BumditbulColor.black800, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: subject.isAllCompleted
                      ? BumditbulColor.green600
                      : BumditbulColor.green400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  subject.name,
                  style: BumditbulTextStyle.headline4.copyWith(fontSize: 14),
                ),
              ),
              Text(
                '$completed / $total',
                style: BumditbulTextStyle.bodyMedium1.copyWith(
                  color: subject.isAllCompleted
                      ? BumditbulColor.green400
                      : BumditbulColor.black500,
                ),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: BumditbulColor.black800,
                valueColor: AlwaysStoppedAnimation<Color>(
                  subject.isAllCompleted
                      ? BumditbulColor.green600
                      : BumditbulColor.green400,
                ),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 10),
            ...subject.tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      task.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 14,
                      color: task.isCompleted
                          ? BumditbulColor.green400
                          : BumditbulColor.black600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.description,
                        style: BumditbulTextStyle.bodyMedium1.copyWith(
                          color: task.isCompleted
                              ? BumditbulColor.black500
                              : BumditbulColor.black400,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: BumditbulColor.black500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
