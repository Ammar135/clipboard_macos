import 'package:flutter/material.dart';

import '../../theme/clipboard_ui_colors.dart';
import '../../theme/clipboard_ui_typography.dart';

class SectionDivider extends StatelessWidget {
  final String label;

  const SectionDivider({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          const Expanded(child: _Line()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: ClipboardUiTypography.sectionLabel(),
            ),
          ),
          const Expanded(child: _Line()),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: ClipboardUiColors.divider,
    );
  }
}
