import 'package:flutter/material.dart';

import '../../models/clipboard_card_ui_model.dart';
import '../../theme/clipboard_ui_colors.dart';
import 'category_filter_chips.dart';
import 'clipboard_sections.dart';
import 'command_bar_header.dart';
import 'footer_hints.dart';
import 'glass_panel.dart';

class ClipboardModernPanel extends StatelessWidget {
  final List<ClipboardCategoryChipUiModel> categoryChips;
  final ClipboardPanelSectionUiModel pinnedSection;
  final List<ClipboardPanelSectionUiModel> sections;
  final int totalItemCount;
  final bool isFilterActive;
  final String emptyMessage;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final ValueChanged<String>? onSearchChanged;
  final Widget? dateFilterButton;
  final VoidCallback? onCloseTap;
  final ValueChanged<ClipboardCategoryChipUiModel>? onCategoryChipTap;
  final ClipboardCardCallback? onItemTap;
  final ClipboardCardCallback? onFavoriteTap;
  final ClipboardMoreTapCallback? onMoreTap;
  final ClipboardQuickActionCallback? onQuickActionTap;
  final VoidCallback? onClearHistoryTap;
  final VoidCallback? onSettingsTap;

  const ClipboardModernPanel({
    super.key,
    required this.categoryChips,
    required this.pinnedSection,
    required this.sections,
    required this.totalItemCount,
    this.isFilterActive = false,
    this.emptyMessage = 'Clipboard is empty',
    this.searchController,
    this.searchFocusNode,
    this.onSearchChanged,
    this.dateFilterButton,
    this.onCloseTap,
    this.onCategoryChipTap,
    this.onItemTap,
    this.onFavoriteTap,
    this.onMoreTap,
    this.onQuickActionTap,
    this.onClearHistoryTap,
    this.onSettingsTap,
  });

  bool get _isEmpty =>
      pinnedSection.isEmpty && sections.every((section) => section.isEmpty);

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        children: [
          CommandBarHeader(
            searchController: searchController,
            searchFocusNode: searchFocusNode,
            onSearchChanged: onSearchChanged,
            isFilterActive: isFilterActive,
            dateFilterButton: dateFilterButton,
            onSettingsTap: onSettingsTap,
            onCloseTap: onCloseTap,
          ),
          const SizedBox(height: 4),
          CategoryFilterChips(
            chips: categoryChips,
            onChipTap: onCategoryChipTap,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isEmpty
                ? Center(
                    child: Text(
                      emptyMessage,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: ClipboardUiColors.textSecondary,
                          ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 8),
                    children: [
                      ClipboardPinnedSection(
                        section: pinnedSection,
                        onItemTap: onItemTap,
                        onFavoriteTap: onFavoriteTap,
                        onMoreTap: onMoreTap,
                        onQuickActionTap: onQuickActionTap,
                      ),
                      ClipboardRecentSections(
                        sections: sections,
                        onItemTap: onItemTap,
                        onFavoriteTap: onFavoriteTap,
                        onMoreTap: onMoreTap,
                        onQuickActionTap: onQuickActionTap,
                      ),
                    ],
                  ),
          ),
          FooterHints(
            itemCount: totalItemCount,
            onClearHistoryTap: onClearHistoryTap,
          ),
        ],
      ),
    );
  }
}
