import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/button/difficulty_dropdown.dart';
import 'package:bumditbul_mobile/core/features/exam_scope/presentation/views/exam_scope_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SubjectCard extends StatelessWidget {
  final ExamSubjectEntry entry;
  final int index;
  final VoidCallback onRemove;
  final void Function(ExamMaterial) onToggleMaterial;
  final VoidCallback onChanged;
  final VoidCallback onDatePick;

  static const _materials = ExamMaterial.values;

  const SubjectCard({
    super.key,
    required this.entry,
    required this.index,
    required this.onRemove,
    required this.onToggleMaterial,
    required this.onChanged,
    required this.onDatePick,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = entry.examDate == null
        ? '시험 날짜'
        : '${entry.examDate!.month}/${entry.examDate!.day}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BumditbulColor.black800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BumditbulColor.black700, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _BorderedField(
                  controller: entry.nameCtrl,
                  hintText: '과목명',
                  onChanged: (_) => onChanged(),
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(width: 8),
              DifficultyDropdown(
                value: entry.difficulty,
                width: 80,
                onChanged: (v) {
                  entry.difficulty = v;
                  onChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onDatePick,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: BumditbulColor.black600, width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: BumditbulColor.black500,
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateText,
                    style: BumditbulTextStyle.bodyMedium1.copyWith(
                      color: entry.examDate == null
                          ? BumditbulColor.black600
                          : BumditbulColor.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _materials.map((mat) {
              final isSelected = entry.ranges.any((r) => r.material == mat);
              return GestureDetector(
                onTap: () => onToggleMaterial(mat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? BumditbulColor.green600.withValues(alpha: 0.15)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? BumditbulColor.green600
                          : BumditbulColor.black600,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mat.label,
                    style: BumditbulTextStyle.bodyMedium2.copyWith(
                      color: isSelected
                          ? BumditbulColor.green400
                          : BumditbulColor.black400,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (entry.ranges.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...entry.ranges.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: BumditbulColor.green600.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        r.material.label,
                        style: BumditbulTextStyle.bodyMedium2.copyWith(
                          color: BumditbulColor.green400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (r.material == ExamMaterial.custom)
                      Expanded(
                        child: _BorderedField(
                          controller: TextEditingController(),
                          hintText: '직접 입력',
                          onChanged: (_) => onChanged(),
                        ),
                      )
                    else ...[
                      SizedBox(
                        width: 56,
                        child: _PageField(hint: 'p', onChanged: onChanged),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '~',
                          style: BumditbulTextStyle.bodyMedium1.copyWith(
                            color: BumditbulColor.black400,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 56,
                        child: _PageField(hint: 'p', onChanged: onChanged),
                      ),
                    ],
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

class _BorderedField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final void Function(String) onChanged;
  final TextInputType? keyboardType;

  const _BorderedField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: BumditbulTextStyle.bodyMedium1.copyWith(
        color: BumditbulColor.white,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: BumditbulTextStyle.bodyMedium1.copyWith(
          color: BumditbulColor.black600,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: BumditbulColor.black600,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: BumditbulColor.green400,
            width: 1,
          ),
        ),
        isDense: true,
      ),
      cursorColor: BumditbulColor.green400,
    );
  }
}

class _PageField extends StatelessWidget {
  final String hint;
  final VoidCallback onChanged;

  const _PageField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: TextField(
        onChanged: (_) => onChanged(),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: BumditbulTextStyle.bodyMedium1.copyWith(
          color: BumditbulColor.white,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: BumditbulTextStyle.bodyMedium1.copyWith(
            color: BumditbulColor.black600,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 0,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: BumditbulColor.black600,
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: BumditbulColor.green400,
              width: 1,
            ),
          ),
          isDense: true,
        ),
        cursorColor: BumditbulColor.green400,
      ),
    );
  }
}
