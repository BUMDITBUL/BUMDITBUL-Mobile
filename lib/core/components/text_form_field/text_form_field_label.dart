import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:flutter/material.dart';

class CustomTextFormFieldLabel extends StatelessWidget {
  const CustomTextFormFieldLabel({
    super.key,
    this.label,
    this.labelText,
    this.labelStyle,
  });

  final Widget? label;
  final String? labelText;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = BumditbulTextStyle.buttonLarge1.copyWith(
      color: BumditbulColor.black500,
    );
    return DefaultTextStyle(
      style: defaultTextStyle.merge(labelStyle),
      child: Row(children: [label ?? Text(labelText!)]),
    );
  }
}
