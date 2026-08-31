import 'package:flutter/material.dart';

import '../../domain/actions/quick_action_resolver.dart';
import '../../domain/entities/clipboard_item.dart';
import '../../domain/entities/content_category.dart';
import '../models/clipboard_card_ui_model.dart';
import '../utils/clipboard_timestamp_formatter.dart';

class ClipboardPanelUiMapper {
  static final _quickActionResolver = QuickActionResolver();

  static const _chipDefinitions = <({String label, ContentCategory? category})>[
    (label: 'All', category: null),
    (label: 'Text', category: ContentCategory.text),
    (label: 'URL', category: ContentCategory.url),
    (label: 'Email', category: ContentCategory.email),
    (label: 'Code', category: ContentCategory.code),
    (label: 'Color', category: ContentCategory.color),
    (label: 'Image', category: ContentCategory.image),
  ];

  static ClipboardPanelViewData map({
    required List<ClipboardItem> items,
    required ContentCategory? categoryFilter,
    required int? selectedItemId,
    required Locale locale,
  }) {
    final filtered = categoryFilter == null
        ? items
        : items.where((item) => item.category == categoryFilter).toList();

    final pinnedListItems = <ClipboardCardUiModel>[];
    final pinnedGridItems = <ClipboardCardUiModel>[];
    final recentByDay = <String, List<ClipboardItem>>{};

    for (final item in filtered) {
      if (item.isFavorite) {
        final layout = _layoutFor(item.category);
        final card = _toCard(item, selectedItemId, locale, layout);
        if (layout == ClipboardCardLayout.grid) {
          pinnedGridItems.add(card);
        } else {
          pinnedListItems.add(card);
        }
      } else {
        final key = _dayKey(item.createdAt);
        recentByDay.putIfAbsent(key, () => []).add(item);
      }
    }

    final sections = <ClipboardPanelSectionUiModel>[];
    final sortedDayKeys = recentByDay.keys.toList()
      ..sort((a, b) => _daySortValue(b).compareTo(_daySortValue(a)));

    for (final dayKey in sortedDayKeys) {
      final dayItems = recentByDay[dayKey]!;
      final listItems = <ClipboardCardUiModel>[];
      final gridItems = <ClipboardCardUiModel>[];

      for (final item in dayItems) {
        final layout = _layoutFor(item.category);
        final card = _toCard(item, selectedItemId, locale, layout);
        if (layout == ClipboardCardLayout.grid) {
          gridItems.add(card);
        } else {
          listItems.add(card);
        }
      }

      sections.add(
        ClipboardPanelSectionUiModel(
          label: '${_sectionLabel(dayKey, locale)} · ${dayItems.length} items',
          listItems: listItems,
          gridItems: gridItems,
        ),
      );
    }

    return ClipboardPanelViewData(
      categoryChips: _chipDefinitions
          .map(
            (chip) => ClipboardCategoryChipUiModel(
              label: chip.label,
              category: chip.category,
              isActive: categoryFilter == chip.category,
            ),
          )
          .toList(),
      pinnedSection: ClipboardPanelSectionUiModel(
        label: 'PINNED',
        listItems: pinnedListItems,
        gridItems: pinnedGridItems,
      ),
      sections: sections,
      totalItemCount: filtered.length,
    );
  }

  static ClipboardCardUiModel _toCard(
    ClipboardItem item,
    int? selectedItemId,
    Locale locale,
    ClipboardCardLayout layout,
  ) {
    final title = item.isImage
        ? (item.sourceApp ?? 'Image')
        : item.content.replaceAll('\n', ' ↵ ');

    return ClipboardCardUiModel(
      itemId: item.id,
      content: item.content,
      category: item.category,
      title: title,
      sourceApp: item.sourceApp ?? 'Unknown App',
      timestampLabel: ClipboardTimestampFormatter.formatRelativeCopiedAt(
        item.createdAt,
        locale,
      ),
      isPinned: item.isFavorite,
      isSelected: item.id == selectedItemId,
      layout: layout,
      colorHex: item.category == ContentCategory.color ? item.content.trim() : null,
      imagePath: item.isImage ? item.content : null,
      quickActionLabels: _quickActionResolver
          .resolve(item)
          .map((action) => action.label)
          .toList(),
    );
  }

  static ClipboardCardLayout _layoutFor(ContentCategory category) {
    return switch (category) {
      ContentCategory.image ||
      ContentCategory.color ||
      ContentCategory.code =>
        ClipboardCardLayout.grid,
      _ => ClipboardCardLayout.list,
    };
  }

  static String _dayKey(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

  static int _daySortValue(String dayKey) {
    final parts = dayKey.split('-').map(int.parse).toList();
    return parts[0] * 10000 + parts[1] * 100 + parts[2];
  }

  static String _sectionLabel(String dayKey, Locale locale) {
    final parts = dayKey.split('-').map(int.parse).toList();
    final date = DateTime(parts[0], parts[1], parts[2]);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (date == today) {
      return 'TODAY';
    }
    if (date == today.subtract(const Duration(days: 1))) {
      return 'YESTERDAY';
    }

    return ClipboardTimestampFormatter.formatCopiedAt(date, locale)
        .split(' · ')
        .first
        .toUpperCase();
  }
}
