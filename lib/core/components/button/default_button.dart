import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final double width;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? textColor;
  final Color? disabledTextColor;
  final BorderSide? borderSide;

  const DefaultButton({
    super.key,
    this.onPressed,
    required this.child,
    this.height = 48,
    this.width = double.infinity,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.textColor,
    this.disabledTextColor,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    final Color resolvedBg = isEnabled
        ? (backgroundColor ?? BumditbulColor.green600)
        : (disabledBackgroundColor ?? BumditbulColor.black600);

    final Color resolvedTextColor = isEnabled
        ? (textColor ?? BumditbulColor.white)
        : (disabledTextColor ?? BumditbulColor.black400);

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: resolvedBg,
          disabledBackgroundColor: disabledBackgroundColor ?? BumditbulColor.black600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: borderSide ?? BorderSide.none,
          ),
          padding: EdgeInsets.zero,
        ),
        child: DefaultTextStyle(
          style: BumditbulTextStyle.bodyLarge1.copyWith(
            color: resolvedTextColor,
          ),
          child: child,
        ),
      ),
    );
  }
}

