import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:flutter/material.dart';

class DefaultModal extends StatelessWidget {
  final String title;
  final Widget content;
  final String? confirmLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onClose;

  const DefaultModal({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel,
    this.onConfirm,
    this.onClose,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    String? confirmLabel,
    VoidCallback? onConfirm,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BumditbulColor.black800,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DefaultModal(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: BumditbulTextStyle.headline3.copyWith(
                  color: BumditbulColor.white,
                ),
              ),
              GestureDetector(
                onTap: onClose ?? () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.close,
                  color: BumditbulColor.black400,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          content,
          if (onConfirm != null) ...[
            const SizedBox(height: 20),
            DefaultButton(
              onPressed: onConfirm,
              child: Text(
                confirmLabel ?? '확인',
                style: BumditbulTextStyle.bodyLarge1.copyWith(
                  color: BumditbulColor.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
