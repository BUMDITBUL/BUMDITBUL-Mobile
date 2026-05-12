import 'package:bumditbul_mobile/constants/app_dimens.dart';
import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:flutter/material.dart';

class ErrorBox extends StatelessWidget {
  final String message;

  const ErrorBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BumditbulColor.red.withValues(alpha: 0.1),
        borderRadius: AppDimens.roundedS,
      ),
      child: Text(
        message,
        style: BumditbulTextStyle.bodySmall.copyWith(color: BumditbulColor.red),
      ),
    );
  }
}
