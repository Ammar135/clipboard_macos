import 'package:flutter/material.dart';

import '../../models/clipboard_card_ui_model.dart';
import '../../theme/clipboard_ui_dimensions.dart';
import 'clipboard_item_card.dart';
import 'section_divider.dart';

typedef ClipboardCardCallback = void Function(ClipboardCardUiModel model);
typedef ClipboardMoreTapCallback = void Function(
  ClipboardCardUiModel model,
  Rect anchor,
);
typedef ClipboardQuickActionCallback = void Function(
  ClipboardCardUiModel model,
  String actionLabel,
);

class ClipboardPinnedSection extends StatelessWidget {
  final ClipboardPanelSectionUiModel section;
  final ClipboardCardCallback? onItemTap;
  final ClipboardCardCallback? onFavoriteTap;
  final ClipboardMoreTapCallback? onMoreTap;
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
  final ClipboardMoreTapCallback? onMoreTap;
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
  final ClipboardMoreTapCallback? onMoreTap;
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
        children: _buildOrderedItemWidgets(),
      ),
    );
  }

  List<Widget> _buildOrderedItemWidgets() {
    final widgets = <Widget>[];
    var index = 0;

    while (index < section.items.length) {
      final item = section.items[index];

      if (item.layout == ClipboardCardLayout.list) {
        if (widgets.isNotEmpty) {
          widgets.add(const SizedBox(height: ClipboardUiDimensions.gridSpacing));
        }
        widgets.add(_buildCard(item));
        index++;
        continue;
      }

      final gridRun = <ClipboardCardUiModel>[];
      while (index < section.items.length &&
          section.items[index].layout == ClipboardCardLayout.grid) {
        gridRun.add(section.items[index]);
        index++;
      }

      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(height: ClipboardUiDimensions.gridSpacing));
      }
      widgets.add(_buildGridRun(gridRun));
    }

    return widgets;
  }

  Widget _buildGridRun(List<ClipboardCardUiModel> gridRun) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 3;
        const spacing = ClipboardUiDimensions.gridSpacing;
        final tileWidth =
            (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: gridRun
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
    );
  }

  Widget _buildCard(ClipboardCardUiModel item) {
    return ClipboardItemCard(
      model: item,
      onTap: onItemTap == null ? null : () => onItemTap!(item),
      onFavoriteTap: onFavoriteTap == null ? null : () => onFavoriteTap!(item),
      onMoreTap: onMoreTap == null ? null : (anchor) => onMoreTap!(item, anchor),
      onQuickActionTap: onQuickActionTap == null
          ? null
          : (label) => onQuickActionTap!(item, label),
    );
  }
}
