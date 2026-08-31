import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/clipboard_ui_colors.dart';
import '../../theme/clipboard_ui_dimensions.dart';
import '../../theme/clipboard_ui_typography.dart';

class CommandBarHeader extends StatelessWidget {
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final ValueChanged<String>? onSearchChanged;
  final bool isFilterActive;
  final Widget? dateFilterButton;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onCloseTap;

  const CommandBarHeader({
    super.key,
    this.searchController,
    this.searchFocusNode,
    this.onSearchChanged,
    this.isFilterActive = false,
    this.dateFilterButton,
    this.onSettingsTap,
    this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ClipboardUiDimensions.headerPadding,
        ClipboardUiDimensions.headerPadding,
        8,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: ClipboardUiColors.searchFill,
                borderRadius: BorderRadius.circular(
                  ClipboardUiDimensions.searchRadius,
                ),
                border: Border.all(color: ClipboardUiColors.borderSubtle),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.search,
                    size: 15,
                    color: ClipboardUiColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      onChanged: onSearchChanged,
                      style: ClipboardUiTypography.searchHint(context).copyWith(
                        color: ClipboardUiColors.textPrimary,
                      ),
                      cursorColor: ClipboardUiColors.accent,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Search clipboard, URLs, code...  ⌘K',
                        hintStyle: ClipboardUiTypography.searchHint(context),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  dateFilterButton ??
                      _HeaderIconButton(
                        icon: CupertinoIcons.calendar,
                        isActive: isFilterActive,
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          _HeaderIconButton(
            icon: CupertinoIcons.gear,
            onTap: onSettingsTap,
          ),
          const SizedBox(width: 4),
          _HeaderIconButton(
            icon: CupertinoIcons.xmark,
            onTap: onCloseTap,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _HeaderIconButton({
    required this.icon,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: isActive
              ? BoxDecoration(
                  color: ClipboardUiColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          child: Icon(
            icon,
            size: 15,
            color: isActive
                ? ClipboardUiColors.accent
                : ClipboardUiColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
