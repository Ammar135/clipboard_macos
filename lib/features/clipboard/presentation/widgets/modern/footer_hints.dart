import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/clipboard_ui_colors.dart';
import '../../theme/clipboard_ui_dimensions.dart';
import '../../theme/clipboard_ui_typography.dart';

class FooterHints extends StatelessWidget {
  final int itemCount;
  final VoidCallback? onClearHistoryTap;

  const FooterHints({
    super.key,
    this.itemCount = 0,
    this.onClearHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ClipboardUiDimensions.footerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ClipboardUiColors.divider)),
      ),
      child: Row(
        children: [
          if (onClearHistoryTap != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onClearHistoryTap,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.trash,
                        size: 12,
                        color: ClipboardUiColors.textTertiary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Clear History',
                        style: ClipboardUiTypography.footerHint(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const Spacer(),
          Text('· $itemCount items', style: ClipboardUiTypography.footerHint()),
        ],
      ),
    );
  }
}
