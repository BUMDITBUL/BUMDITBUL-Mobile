import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/constants/app_dimens.dart';
import 'package:flutter/material.dart';

class DifficultyDropdown extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;
  final double? width;

  static const _options = ['상', '중', '하'];

  const DifficultyDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '난이도 선택',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDropdown(context),
          borderRadius: radiusS,
          child: Container(
            width: width,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BumditbulColor.black800,
              border: Border.all(color: BumditbulColor.black600, width: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: BumditbulTextStyle.bodyMedium1.copyWith(
                    color: BumditbulColor.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: BumditbulColor.black400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDropdown(BuildContext context) async {
    final boxObject = context.findRenderObject();
    final overlayObject = Navigator.of(context).overlay?.context.findRenderObject();
    if (boxObject is! RenderBox || overlayObject is! RenderBox) return;
    final RenderBox box = boxObject;
    final RenderBox overlay = overlayObject;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(box.size.bottomLeft(Offset.zero), ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<String>(
      context: context,
      position: position,
      color: BumditbulColor.black800,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: BumditbulColor.black700, width: 0.5),
      ),
      items: _options.map((opt) {
        final isSelected = opt == value;
        return PopupMenuItem<String>(
          value: opt,
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: isSelected
                ? BoxDecoration(
                    color: BumditbulColor.black600.withValues(alpha: 0.15),
                  )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  opt,
                  style: BumditbulTextStyle.bodyLarge2.copyWith(
                    color: isSelected
                        ? BumditbulColor.green400
                        : BumditbulColor.white,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check,
                    color: BumditbulColor.green400,
                    size: 16,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );

    if (selected != null) {
      onChanged(selected);
    }
  }
}

Widget dismissBackground({
  double borderRadius = 12,
  EdgeInsets margin = const EdgeInsets.only(bottom: 12),
}) {
  return Container(
    margin: margin,
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    decoration: BoxDecoration(
      color: BumditbulColor.red,
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.delete_outline, color: BumditbulColor.white, size: 24),
        const SizedBox(height: 4),
        Text(
          '삭제',
          style: BumditbulTextStyle.bodyMedium2.copyWith(
            color: BumditbulColor.white,
          ),
        ),
      ],
    ),
  );
}
