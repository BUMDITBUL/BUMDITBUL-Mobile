import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:flutter/material.dart';

class SelectButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? BumditbulColor.green600 : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? BumditbulColor.green600
                : BumditbulColor.black600,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: BumditbulTextStyle.bodyMedium1.copyWith(
            color: isSelected ? BumditbulColor.white : BumditbulColor.black500,
          ),
        ),
      ),
    );
  }
}
