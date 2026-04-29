import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/providers/study_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MonthCalendar extends ConsumerWidget {
  const MonthCalendar({super.key});

  static const _dayNames = ['일', '월', '화', '수', '목', '금', '토'];
  static const _monthNames = [
    '1월',
    '2월',
    '3월',
    '4월',
    '5월',
    '6월',
    '7월',
    '8월',
    '9월',
    '10월',
    '11월',
    '12월',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final displayMonth = ref.watch(displayMonthProvider);
    final studyState = ref.watch(studyProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: BumditbulColor.black800,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildHeader(ref, displayMonth),
          const SizedBox(height: 8),
          _buildDayNames(),
          const SizedBox(height: 4),
          _buildGrid(ref, displayMonth, selectedDate, studyState),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref, DateTime displayMonth) {
    final label =
        '${displayMonth.year}년 ${_monthNames[displayMonth.month - 1]}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavButton(
            icon: Icons.chevron_left,
            onTap: () {
              final prev = DateTime(
                displayMonth.year,
                displayMonth.month - 1,
                1,
              );
              ref.read(displayMonthProvider.notifier).state = prev;
            },
          ),
          Text(
            label,
            style: BumditbulTextStyle.headline4.copyWith(
              color: BumditbulColor.white,
              fontSize: 15,
            ),
          ),
          _NavButton(
            icon: Icons.chevron_right,
            onTap: () {
              final next = DateTime(
                displayMonth.year,
                displayMonth.month + 1,
                1,
              );
              ref.read(displayMonthProvider.notifier).state = next;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayNames() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: _dayNames.asMap().entries.map((entry) {
          final idx = entry.key;
          final name = entry.value;
          Color color = BumditbulColor.black500;
          if (idx == 0) color = const Color(0xFFEF5350);
          if (idx == 6) color = const Color(0xFF42A5F5);
          return Expanded(
            child: Center(
              child: Text(
                name,
                style: BumditbulTextStyle.bodyMedium2.copyWith(color: color),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGrid(
    WidgetRef ref,
    DateTime displayMonth,
    DateTime selectedDate,
    StudyState studyState,
  ) {
    final firstDay = DateTime(displayMonth.year, displayMonth.month, 1);
    final startOffset = firstDay.weekday % 7;
    final daysInMonth = DateUtils.getDaysInMonth(
      displayMonth.year,
      displayMonth.month,
    );
    final today = DateTime.now();
    final rows = ((startOffset + daysInMonth) / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final dayNum = row * 7 + col - startOffset + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 36));
              }

              final cellDate = DateTime(
                displayMonth.year,
                displayMonth.month,
                dayNum,
              );
              final isSelected = DateUtils.isSameDay(cellDate, selectedDate);
              final isToday = DateUtils.isSameDay(cellDate, today);
              final hasTasks = studyState.hasTasksOnDate(cellDate);

              Color dayColor = BumditbulColor.white;
              if (col == 0) dayColor = const Color(0xFFEF5350);
              if (col == 6) dayColor = const Color(0xFF42A5F5);
              if (isSelected) dayColor = BumditbulColor.white;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(selectedDateProvider.notifier).state = cellDate;
                    ref.read(displayMonthProvider.notifier).state = DateTime(
                      cellDate.year,
                      cellDate.month,
                      1,
                    );
                  },
                  child: Container(
                    height: 36,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? BumditbulColor.green600
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(color: BumditbulColor.green400, width: 1)
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: BumditbulTextStyle.bodyMedium1.copyWith(
                            color: dayColor,
                            fontWeight: (isToday || isSelected)
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        if (hasTasks && !isSelected)
                          Positioned(
                            bottom: 4,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: BumditbulColor.green400,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: BumditbulColor.black400, size: 22),
      ),
    );
  }
}
