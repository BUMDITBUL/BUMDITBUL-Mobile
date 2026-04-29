import 'package:bumditbul_mobile/constants/app_dimens.dart';
import 'package:bumditbul_mobile/constants/app_strings.dart';
import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:flutter/material.dart';

abstract final class AppDialog {
  static Future<bool?> showUnsaved(BuildContext context) {
    return _showConfirm(
      context: context,
      icon: Icons.warning_amber_rounded,
      iconColor: BumditbulColor.green400,
      title: AppStrings.dialogUnsavedTitle,
      body: AppStrings.dialogUnsavedBody,
      confirmLabel: AppStrings.btnLeave,
      confirmColor: BumditbulColor.green600,
    );
  }

  static Future<bool?> showWithdrawal(BuildContext context) {
    return _showConfirm(
      context: context,
      icon: Icons.warning_amber_rounded,
      iconColor: BumditbulColor.red,
      title: AppStrings.dialogWithdrawalTitle,
      body: AppStrings.dialogWithdrawalBody,
      confirmLabel: AppStrings.btnWithdraw,
      confirmColor: BumditbulColor.red,
    );
  }

  static Future<bool?> _showConfirm({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: BumditbulColor.popUp,
        shape: RoundedRectangleBorder(borderRadius: AppDimens.roundedXL),
        child: Padding(
          padding: AppDimens.dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 40),
              AppDimens.gap16,
              Text(
                title,
                style: BumditbulTextStyle.headline3
                    .copyWith(color: BumditbulColor.white),
              ),
              AppDimens.gap8,
              Text(
                body,
                textAlign: TextAlign.center,
                style: BumditbulTextStyle.bodyMedium1
                    .copyWith(color: BumditbulColor.black400, fontSize: 13),
              ),
              AppDimens.gap24,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: BumditbulColor.black600),
                        shape: RoundedRectangleBorder(
                            borderRadius: AppDimens.roundedS),
                        padding: AppDimens.buttonVerticalPadding,
                      ),
                      child: Text(
                        AppStrings.btnCancel,
                        style: BumditbulTextStyle.bodyLarge1
                            .copyWith(color: BumditbulColor.black400),
                      ),
                    ),
                  ),
                  AppDimens.gapH12,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppDimens.roundedS),
                        padding: AppDimens.buttonVerticalPadding,
                      ),
                      child: Text(
                        confirmLabel,
                        style: BumditbulTextStyle.bodyLarge1
                            .copyWith(color: BumditbulColor.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
