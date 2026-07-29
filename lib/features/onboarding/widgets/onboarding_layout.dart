import 'package:flutter/material.dart';


class OnboardingLayout {
  OnboardingLayout._();

  static const double canvasWidth = 312;
  static const double canvasHeight = 679;

  // Avatar — centered at x=156 (dead center), measured ring diameter ~96.
  static const double avatarSize = 100;
  static const double avatarCenterX = canvasWidth / 2;
  static const double avatarCenterY = 224;
  static double get avatarTop => avatarCenterY - avatarSize / 2;
  static double get avatarLeft => avatarCenterX - avatarSize / 2;

  // Badge slots
  static const double topLeftBadgeTop = 125;
  static const double topLeftBadgeLeft = 30;

  static const double topRightBadgeTop = 165;
  static const double topRightBadgeRight = 17;

  // Overlaps the avatar's bottom edge, offset ~21px right of center.
  static const double overlapBadgeTop = 257;
  static const Alignment overlapBadgeAlignment = Alignment(0.135, 0);

  static const double extraBadgeTop = 294;
  static const double extraBadgeRight = 21;

  // Headline / subtitle
  static const double headlineTop = 352;
  static const double headlineHorizontalPadding = 24;
  static const double subtitleTop = 430;
  static const double subtitleHorizontalPadding = 32;

  // Bottom sheet
  static const double sheetHeight = 167;
  static const double sheetTopPadding = 27;
  static const double sheetGapDotsToButton = 28;
  static const double buttonHeight = 44;
  static const double buttonHorizontalMargin = 20;
  static const double sheetGapButtonToLink = 18;

  static Widget topLeft({required Widget child}) =>
      Positioned(top: topLeftBadgeTop, left: topLeftBadgeLeft, child: child);

  static Widget topRight({required Widget child}) => Positioned(
        top: topRightBadgeTop,
        right: topRightBadgeRight,
        child: child,
      );

  static Widget overlap({required Widget child}) => Positioned(
        top: overlapBadgeTop,
        left: 0,
        right: 0,
        child: Align(alignment: overlapBadgeAlignment, child: child),
      );

  static Widget extra({required Widget child}) =>
      Positioned(top: extraBadgeTop, right: extraBadgeRight, child: child);
}