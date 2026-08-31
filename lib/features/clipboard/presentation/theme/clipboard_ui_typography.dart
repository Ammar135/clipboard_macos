import 'package:flutter/material.dart';

import 'clipboard_ui_colors.dart';

abstract final class ClipboardUiTypography {
  static const String fontFamily = '.AppleSystemUIFont';

  static TextStyle searchHint(BuildContext context) {
    return const TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: ClipboardUiColors.textSecondary,
      letterSpacing: -0.15,
    );
  }

  static TextStyle chipLabel({required bool isActive}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: isActive ? Colors.white : ClipboardUiColors.textSecondary,
      letterSpacing: -0.1,
    );
  }

  static TextStyle cardTitle({bool isSelected = false}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: ClipboardUiColors.textPrimary,
      letterSpacing: -0.2,
      height: 1.25,
    );
  }

  static TextStyle cardMeta() {
    return const TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: ClipboardUiColors.textSecondary,
      letterSpacing: -0.05,
      height: 1.2,
    );
  }

  static TextStyle sectionLabel() {
    return const TextStyle(
      fontFamily: fontFamily,
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: ClipboardUiColors.textTertiary,
      letterSpacing: 0.8,
    );
  }

  static TextStyle footerHint() {
    return const TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: ClipboardUiColors.textTertiary,
      letterSpacing: -0.05,
    );
  }

  static TextStyle quickActionLabel() {
    return const TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: ClipboardUiColors.textPrimary,
      letterSpacing: -0.05,
    );
  }
}
