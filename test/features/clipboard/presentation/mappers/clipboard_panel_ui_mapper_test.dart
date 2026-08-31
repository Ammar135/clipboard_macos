import 'package:clipboard_project/features/clipboard/domain/entities/clipboard_item.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/content_category.dart';
import 'package:clipboard_project/features/clipboard/presentation/mappers/clipboard_panel_ui_mapper.dart';
import 'package:clipboard_project/features/clipboard/presentation/models/clipboard_card_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  test('maps pinned and today sections with category chips', () {
    final now = DateTime.now();
    final items = [
      ClipboardItem(
        id: 1,
        content: 'pinned url',
        category: ContentCategory.url,
        createdAt: now,
        sourceApp: 'Safari',
        isFavorite: true,
      ),
      ClipboardItem(
        id: 2,
        content: 'recent text',
        category: ContentCategory.text,
        createdAt: now,
        sourceApp: 'Notes',
        isFavorite: false,
      ),
    ];

    final viewData = ClipboardPanelUiMapper.map(
      items: items,
      categoryFilter: null,
      selectedItemId: 2,
      locale: const Locale('en'),
    );

    expect(viewData.pinnedItems, hasLength(1));
    expect(viewData.pinnedItems.first.itemId, 1);
    expect(viewData.sections, hasLength(1));
    expect(viewData.sections.first.listItems, hasLength(1));
    expect(viewData.sections.first.listItems.first.isSelected, isTrue);
    expect(viewData.totalItemCount, 2);
    expect(
      viewData.categoryChips.firstWhere((chip) => chip.label == 'All').isActive,
      isTrue,
    );
  });

  test('filters items by category', () {
    final now = DateTime.now();
    final items = [
      ClipboardItem(
        id: 1,
        content: 'https://example.com',
        category: ContentCategory.url,
        createdAt: now,
        isFavorite: false,
      ),
      ClipboardItem(
        id: 2,
        content: 'plain text',
        category: ContentCategory.text,
        createdAt: now,
        isFavorite: false,
      ),
    ];

    final viewData = ClipboardPanelUiMapper.map(
      items: items,
      categoryFilter: ContentCategory.url,
      selectedItemId: null,
      locale: const Locale('en'),
    );

    expect(viewData.totalItemCount, 1);
    expect(viewData.sections.first.listItems.single.category, ContentCategory.url);
  });

  test('uses grid layout for code, color, and image categories', () {
    final now = DateTime.now();
    final items = [
      ClipboardItem(
        id: 1,
        content: 'const x = 1;',
        category: ContentCategory.code,
        createdAt: now,
        isFavorite: false,
      ),
    ];

    final viewData = ClipboardPanelUiMapper.map(
      items: items,
      categoryFilter: null,
      selectedItemId: null,
      locale: const Locale('en'),
    );

    expect(viewData.sections.first.gridItems, hasLength(1));
    expect(
      viewData.sections.first.gridItems.first.layout,
      ClipboardCardLayout.grid,
    );
  });
}
