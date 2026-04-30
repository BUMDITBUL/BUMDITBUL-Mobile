import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showExamDatePickerSheet(
  BuildContext context, {
  DateTime? initialDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: BumditbulColor.black850,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (ctx) => _ExamDatePickerSheet(initialDate: initialDate),
  );
}

class _ExamDatePickerSheet extends StatefulWidget {
  final DateTime? initialDate;

  const _ExamDatePickerSheet({this.initialDate});

  @override
  State<_ExamDatePickerSheet> createState() => _ExamDatePickerSheetState();
}

class _ExamDatePickerSheetState extends State<_ExamDatePickerSheet> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  late FixedExtentScrollController _yearCtrl;
  late FixedExtentScrollController _monthCtrl;
  late FixedExtentScrollController _dayCtrl;

  static const double _itemExtent = 44.0;
  static const int _visibleCount = 5;

  final int _startYear = 2024;
  final int _endYear = 2030;

  List<int> get _years =>
      List.generate(_endYear - _startYear + 1, (i) => _startYear + i);

  List<int> get _months => List.generate(12, (i) => i + 1);

  int get _daysInMonth =>
      DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);

  List<int> get _days => List.generate(_daysInMonth, (i) => i + 1);

  @override
  void initState() {
    super.initState();
    final initial =
        widget.initialDate ?? DateTime.now().add(const Duration(days: 14));

    _selectedYear = initial.year.clamp(_startYear, _endYear);
    _selectedMonth = initial.month;
    _selectedDay = initial.day.clamp(
      1,
      DateUtils.getDaysInMonth(_selectedYear, initial.month),
    );

    _yearCtrl = FixedExtentScrollController(
      initialItem: _selectedYear - _startYear,
    );
    _monthCtrl = FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _dayCtrl = FixedExtentScrollController(initialItem: _selectedDay - 1);
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    super.dispose();
  }

  void _clampDay() {
    final maxDay = DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
    if (_selectedDay > maxDay) {
      _selectedDay = maxDay;
      _dayCtrl.jumpToItem(_selectedDay - 1);
    }
  }

  String get _weekdayLabel {
    final date = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    const labels = ['월', '화', '수', '목', '금', '토', '일'];
    return labels[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: BumditbulColor.black600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.chevron_left,
                    color: BumditbulColor.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '날짜선택',
                  style: BumditbulTextStyle.headline3.copyWith(
                    color: BumditbulColor.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$_selectedYear년 $_selectedMonth월',
              style: BumditbulTextStyle.bodyMedium1.copyWith(
                color: BumditbulColor.black400,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: _itemExtent * _visibleCount,
              child: Row(
                children: [
                  Expanded(child: _buildYearPicker()),
                  Expanded(child: _buildMonthPicker()),
                  Expanded(child: _buildDayPicker()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            DefaultButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(DateTime(_selectedYear, _selectedMonth, _selectedDay));
              },
              backgroundColor: BumditbulColor.green600,
              child: Text(
                '$_selectedMonth월 $_selectedDay일 $_weekdayLabel요일 선택',
                style: BumditbulTextStyle.bodyLarge1.copyWith(
                  color: BumditbulColor.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearPicker() {
    return _PickerColumn(
      controller: _yearCtrl,
      items: _years,
      selectedIndex: _selectedYear - _startYear,
      itemExtent: _itemExtent,
      labelBuilder: (v) => '$v년',
      onSelected: (v) {
        setState(() {
          _selectedYear = v;
          _clampDay();
        });
      },
    );
  }

  Widget _buildMonthPicker() {
    return _PickerColumn(
      controller: _monthCtrl,
      items: _months,
      selectedIndex: _selectedMonth - 1,
      itemExtent: _itemExtent,
      labelBuilder: (v) => '$v월',
      onSelected: (v) {
        setState(() {
          _selectedMonth = v;
          _clampDay();
        });
      },
    );
  }

  Widget _buildDayPicker() {
    return _PickerColumn(
      controller: _dayCtrl,
      items: _days,
      selectedIndex: (_selectedDay - 1).clamp(0, _days.length - 1),
      itemExtent: _itemExtent,
      labelBuilder: (v) => '$v일',
      onSelected: (v) {
        setState(() => _selectedDay = v);
      },
    );
  }
}

class _PickerColumn extends StatelessWidget {
  final FixedExtentScrollController controller;
  final List<int> items;
  final int selectedIndex;
  final double itemExtent;
  final String Function(int) labelBuilder;
  final void Function(int) onSelected;

  const _PickerColumn({
    required this.controller,
    required this.items,
    required this.selectedIndex,
    required this.itemExtent,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          child: Container(
            height: itemExtent,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: BumditbulColor.black850,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: itemExtent,
          physics: const FixedExtentScrollPhysics(),
          perspective: 0.003,
          diameterRatio: 2.5,
          onSelectedItemChanged: (idx) {
            if (idx >= 0 && idx < items.length) {
              onSelected(items[idx]);
            }
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: items.length,
            builder: (ctx, idx) {
              final isSelected = idx == selectedIndex;
              return Center(
                child: Text(
                  labelBuilder(items[idx]),
                  style: BumditbulTextStyle.bodyLarge1.copyWith(
                    color: isSelected
                        ? BumditbulColor.white
                        : BumditbulColor.black600,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: isSelected ? 16 : 14,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
