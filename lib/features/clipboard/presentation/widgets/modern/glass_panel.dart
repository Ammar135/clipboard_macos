import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/clipboard_ui_colors.dart';
import '../../theme/clipboard_ui_dimensions.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const GlassPanel({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ClipboardUiDimensions.windowRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: width ?? ClipboardUiDimensions.panelWidth,
          height: height ?? ClipboardUiDimensions.panelHeight,
          decoration: BoxDecoration(
            color: ClipboardUiColors.windowBackground,
            borderRadius:
                BorderRadius.circular(ClipboardUiDimensions.windowRadius),
            border: Border.all(color: ClipboardUiColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
