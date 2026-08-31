import 'package:flutter/material.dart';

/// Color palette matched to the macOS dark glass clipboard manager mockup.
abstract final class ClipboardUiColors {
  static const Color windowTint = Color(0xFF1E1E1E);
  static const double windowTintOpacity = 0.70;

  static const Color accent = Color(0xFF5E5CE6);
  static const Color accentGlow = Color(0x665E5CE6);

  static const Color textPrimary = Color(0xFFF2F2F7);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFF636366);

  static const Color searchFill = Color(0x33FFFFFF);
  static const Color cardFill = Color(0xFF2C2C2E);
  static const Color cardFillHover = Color(0xFF3A3A3C);
  static const Color chipInactiveFill = Color(0x1AFFFFFF);
  static const Color chipInactiveBorder = Color(0x33FFFFFF);

  static const Color borderSubtle = Color(0x1AFFFFFF);
  static const Color divider = Color(0x26FFFFFF);

  static const Color quickActionFill = Color(0x33FFFFFF);
  static const Color quickActionBorder = Color(0x40FFFFFF);

  static Color get windowBackground =>
      windowTint.withValues(alpha: windowTintOpacity);
}
