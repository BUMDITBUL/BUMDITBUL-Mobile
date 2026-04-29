import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/constants/app_dimens.dart';
import 'package:flutter/material.dart';

class StudyListButton extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onTap;

  const StudyListButton({
    super.key,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: isCompleted,
      label: isCompleted ? '완료' : '미완료',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radiusXXL,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? BumditbulColor.green600.withValues(alpha: 0.15)
                  : Colors.transparent,
              border: Border.all(
                color: isCompleted
                    ? BumditbulColor.green600
                    : BumditbulColor.black500,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 14,
                  color: isCompleted
                      ? BumditbulColor.green400
                      : BumditbulColor.black500,
                ),
                const SizedBox(width: 4),
                Text(
                  isCompleted ? '완료' : '미완료',
                  style: BumditbulTextStyle.bodyMedium2.copyWith(
                    color: isCompleted
                        ? BumditbulColor.green400
                        : BumditbulColor.black500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
