import 'package:flutter/material.dart';

import '../../models/clipboard_card_ui_model.dart';
import '../../theme/clipboard_ui_dimensions.dart';
import 'clipboard_item_card.dart';
import 'section_divider.dart';

typedef ClipboardCardCallback = void Function(ClipboardCardUiModel model);
typedef ClipboardQuickActionCallback = void Function(
  ClipboardCardUiModel model,
  String actionLabel,
);

class ClipboardPinnedSection extends StatelessWidget {
  final ClipboardPanelSectionUiModel section;
  final ClipboardCardCallback? onItemTap;
  final ClipboardCardCallback? onFavoriteTap;
  final ClipboardCardCallback? onMoreTap;
  final ClipboardQuickActionCallback? onQuickActionTap;

  const ClipboardPinnedSection({
    super.key,
    required this.section,
    this.onItemTap,
    this.onFavoriteTap,
    this.onMoreTap,
    this.onQuickActionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (section.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SectionDivider(label: 'PINNED'),
        ClipboardSectionItems(
          section: section,
          onItemTap: onItemTap,
          onFavoriteTap: onFavoriteTap,
          onMoreTap: onMoreTap,
          onQuickActionTap: onQuickActionTap,
        ),
      ],
    );
  }
}

class ClipboardRecentSections extends StatelessWidget {
  final List<ClipboardPanelSectionUiModel> sections;
  final ClipboardCardCallback? onItemTap;
  final ClipboardCardCallback? onFavoriteTap;
  final ClipboardCardCallback? onMoreTap;
  final ClipboardQuickActionCallback? onQuickActionTap;

  const ClipboardRecentSections({
    super.key,
    required this.sections,
    this.onItemTap,
    this.onFavoriteTap,
    this.onMoreTap,
    this.onQuickActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final section in sections)
          if (!section.isEmpty) ...[
            SectionDivider(label: section.label),
            ClipboardSectionItems(
              section: section,
              onItemTap: onItemTap,
              onFavoriteTap: onFavoriteTap,
              onMoreTap: onMoreTap,
              onQuickActionTap: onQuickActionTap,
            ),
          ],
      ],
    );
  }
}

class ClipboardSectionItems extends StatelessWidget {
  final ClipboardPanelSectionUiModel section;
  final ClipboardCardCallback? onItemTap;
  final ClipboardCardCallback? onFavoriteTap;
  final ClipboardCardCallback? onMoreTap;
  final ClipboardQuickActionCallback? onQuickActionTap;

  const ClipboardSectionItems({
    super.key,
    required this.section,
    this.onItemTap,
    this.onFavoriteTap,
    this.onMoreTap,
    this.onQuickActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ClipboardUiDimensions.contentPadding,
      ),
      child: Column(
        children: [
          for (var i = 0; i < section.listItems.length; i++) ...[
            if (i > 0) const SizedBox(height: ClipboardUiDimensions.gridSpacing),
            _buildCard(section.listItems[i]),
          ],
          if (section.listItems.isNotEmpty && section.gridItems.isNotEmpty)
            const SizedBox(height: ClipboardUiDimensions.gridSpacing),
          if (section.gridItems.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                const crossAxisCount = 3;
                const spacing = ClipboardUiDimensions.gridSpacing;
                final tileWidth =
                    (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                        crossAxisCount;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: section.gridItems
                      .map(
                        (item) => SizedBox(
                          width: tileWidth,
                          height: 118,
                          child: _buildCard(item),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCard(ClipboardCardUiModel item) {
    return ClipboardItemCard(
      model: item,
      onTap: onItemTap == null ? null : () => onItemTap!(item),
      onFavoriteTap: onFavoriteTap == null ? null : () => onFavoriteTap!(item),
      onMoreTap: onMoreTap == null ? null : () => onMoreTap!(item),
      onQuickActionTap: onQuickActionTap == null
          ? null
          : (label) => onQuickActionTap!(item, label),
    );
  }
}
