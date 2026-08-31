import 'package:flutter/material.dart';

import '../../theme/clipboard_ui_colors.dart';
import '../../theme/clipboard_ui_dimensions.dart';
import '../../theme/clipboard_ui_typography.dart';

class QuickActionsMenu extends StatelessWidget {
  final List<String> actions;
  final ValueChanged<String>? onActionTap;

  const QuickActionsMenu({
    super.key,
    required this.actions,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          _QuickActionButton(
            label: actions[i],
            onTap: onActionTap == null ? null : () => onActionTap!(actions[i]),
          ),
        ],
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(ClipboardUiDimensions.quickActionRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: ClipboardUiColors.quickActionFill,
            borderRadius:
                BorderRadius.circular(ClipboardUiDimensions.quickActionRadius),
            border: Border.all(color: ClipboardUiColors.quickActionBorder),
          ),
          child: Text(
            label,
            style: ClipboardUiTypography.quickActionLabel(),
          ),
        ),
      ),
    );
  }
}
