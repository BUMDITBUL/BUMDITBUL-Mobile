import 'package:flutter/material.dart';

abstract final class AppDimens {
  /// 세로 간격 (SizedBox height)
  static const SizedBox gap4 = SizedBox(height: 4);
  static const SizedBox gap6 = SizedBox(height: 6);
  static const SizedBox gap8 = SizedBox(height: 8);
  static const SizedBox gap10 = SizedBox(height: 10);
  static const SizedBox gap12 = SizedBox(height: 12);
  static const SizedBox gap16 = SizedBox(height: 16);
  static const SizedBox gap20 = SizedBox(height: 20);
  static const SizedBox gap24 = SizedBox(height: 24);
  static const SizedBox gap32 = SizedBox(height: 32);
  static const SizedBox gap40 = SizedBox(height: 40);

  /// 가로 간격 (SizedBox width
  static const SizedBox gapH4 = SizedBox(width: 4);
  static const SizedBox gapH6 = SizedBox(width: 6);
  static const SizedBox gapH8 = SizedBox(width: 8);
  static const SizedBox gapH10 = SizedBox(width: 10);
  static const SizedBox gapH12 = SizedBox(width: 12);
  static const SizedBox gapH16 = SizedBox(width: 16);

  /// Border Radius
  static const double radiusXS = 6;
  static const double radiusS = 8;
  static const double radiusM = 10;
  static const double radiusL = 12;
  static const double radiusXL = 16;
  static const double radiusXXL = 20;

  static final BorderRadius roundedXS = BorderRadius.circular(radiusXS);
  static final BorderRadius roundedS = BorderRadius.circular(radiusS);
  static final BorderRadius roundedM = BorderRadius.circular(radiusM);
  static final BorderRadius roundedL = BorderRadius.circular(radiusL);
  static final BorderRadius roundedXL = BorderRadius.circular(radiusXL);
  static final BorderRadius roundedXXL = BorderRadius.circular(radiusXXL);
  static final BorderRadius roundedTopXXL =
      const BorderRadius.vertical(top: Radius.circular(radiusXXL));

  /// Padding
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets cardPaddingS =
      EdgeInsets.symmetric(horizontal: 14, vertical: 12);
  static const EdgeInsets fieldPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 12);
  static const EdgeInsets buttonVerticalPadding =
      EdgeInsets.symmetric(vertical: 12);
  static const EdgeInsets dialogPadding = EdgeInsets.all(24);
}
