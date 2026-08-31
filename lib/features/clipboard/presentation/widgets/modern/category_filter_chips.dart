import 'package:flutter/material.dart';

import '../../models/clipboard_card_ui_model.dart';
import '../../theme/clipboard_ui_colors.dart';
import '../../theme/clipboard_ui_dimensions.dart';
import '../../theme/clipboard_ui_typography.dart';

class CategoryFilterChips extends StatelessWidget {
  final List<ClipboardCategoryChipUiModel> chips;
  final ValueChanged<ClipboardCategoryChipUiModel>? onChipTap;

  const CategoryFilterChips({
    super.key,
    required this.chips,
    this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: ClipboardUiDimensions.contentPadding,
        ),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final chip = chips[index];
          return _CategoryChip(
            label: chip.label,
            isActive: chip.isActive,
            onTap: onChipTap == null ? null : () => onChipTap!(chip),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ClipboardUiDimensions.chipRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? ClipboardUiColors.accent
                : ClipboardUiColors.chipInactiveFill,
            borderRadius:
                BorderRadius.circular(ClipboardUiDimensions.chipRadius),
            border: Border.all(
              color: isActive
                  ? ClipboardUiColors.accent
                  : ClipboardUiColors.chipInactiveBorder,
            ),
          ),
          child: Text(
            label,
            style: ClipboardUiTypography.chipLabel(isActive: isActive),
          ),
        ),
      ),
    );
  }
}
