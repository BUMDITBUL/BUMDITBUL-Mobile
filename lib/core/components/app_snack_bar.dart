import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:flutter/material.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Align(
          alignment: Alignment.center,
          child: Text(
            message,
            style: BumditbulTextStyle.bodyMedium1.copyWith(
              color: BumditbulColor.white,
            ),
          ),
        ),
        backgroundColor:
            isError ? BumditbulColor.red : BumditbulColor.green600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
}
