import 'package:bumditbul_mobile/constants/color.dart';
import 'package:flutter/material.dart';

class BumditbulTextStyle {
  /// headline
  static TextStyle headline2 = defaultTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headline3 = defaultTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headline4 = defaultTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headline5 = defaultTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  /// body
  static TextStyle bodyLarge1 = defaultTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyLarge2 = defaultTextStyle.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyMedium1 = defaultTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyMedium2 = defaultTextStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodySmall = defaultTextStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  /// button
  static TextStyle buttonLarge1 = defaultTextStyle.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static TextStyle buttonLarge2 = defaultTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle buttonMedium = defaultTextStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  static TextStyle buttonSmall = defaultTextStyle.copyWith(
    fontSize: 6,
    fontWeight: FontWeight.w400,
  );
}

const TextStyle defaultTextStyle = TextStyle(
  color: BumditbulColor.white,
  fontFamily: 'Inter',
);
