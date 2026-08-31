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

    expect(viewData.pinnedSection.items, hasLength(1));
    expect(viewData.pinnedSection.items.first.itemId, 1);
    expect(viewData.sections, hasLength(1));
    expect(viewData.sections.first.items, hasLength(1));
    expect(viewData.sections.first.items.first.isSelected, isTrue);
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
    expect(viewData.sections.first.items.single.category, ContentCategory.url);
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
      ClipboardItem(
        id: 2,
        content: '#FF5733',
        category: ContentCategory.color,
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

    expect(viewData.sections.first.items, hasLength(2));
    expect(
      viewData.sections.first.items.last.layout,
      ClipboardCardLayout.grid,
    );
  });

  test('pinned items keep category layout', () {
    final now = DateTime.now();
    final items = [
      ClipboardItem(
        id: 1,
        content: 'const x = 1;',
        category: ContentCategory.code,
        createdAt: now,
        isFavorite: true,
      ),
    ];

    final viewData = ClipboardPanelUiMapper.map(
      items: items,
      categoryFilter: null,
      selectedItemId: null,
      locale: const Locale('en'),
    );

    expect(viewData.pinnedSection.items, hasLength(1));
    expect(
      viewData.pinnedSection.items.first.layout,
      ClipboardCardLayout.grid,
    );
  });

  test('keeps chronological order when mixing list and grid layouts', () {
    final now = DateTime.now();
    final items = [
      ClipboardItem(
        id: 1,
        content: 'newest text',
        category: ContentCategory.text,
        createdAt: now,
        isFavorite: false,
      ),
      ClipboardItem(
        id: 2,
        content: '#FF5733',
        category: ContentCategory.color,
        createdAt: now.subtract(const Duration(minutes: 1)),
        isFavorite: false,
      ),
      ClipboardItem(
        id: 3,
        content: 'older text',
        category: ContentCategory.text,
        createdAt: now.subtract(const Duration(minutes: 2)),
        isFavorite: false,
      ),
      ClipboardItem(
        id: 4,
        content: '/tmp/image.png',
        category: ContentCategory.image,
        createdAt: now.subtract(const Duration(minutes: 3)),
        isFavorite: false,
      ),
    ];

    final viewData = ClipboardPanelUiMapper.map(
      items: items,
      categoryFilter: null,
      selectedItemId: null,
      locale: const Locale('en'),
    );

    expect(
      viewData.sections.first.items.map((item) => item.itemId).toList(),
      [1, 2, 3, 4],
    );
    expect(viewData.sections.first.items[0].layout, ClipboardCardLayout.list);
    expect(viewData.sections.first.items[1].layout, ClipboardCardLayout.grid);
    expect(viewData.sections.first.items[2].layout, ClipboardCardLayout.list);
    expect(viewData.sections.first.items[3].layout, ClipboardCardLayout.grid);
  });

  test('maps quick actions per category', () {
    final now = DateTime.now();
    final urlItem = ClipboardItem(
      id: 1,
      content: 'https://example.com',
      category: ContentCategory.url,
      createdAt: now,
      isFavorite: false,
    );
    final textItem = ClipboardItem(
      id: 2,
      content: 'hello',
      category: ContentCategory.text,
      createdAt: now,
      isFavorite: false,
    );

    final viewData = ClipboardPanelUiMapper.map(
      items: [urlItem, textItem],
      categoryFilter: null,
      selectedItemId: null,
      locale: const Locale('en'),
    );

    expect(
      viewData.sections.first.items.first.quickActionLabels,
      ['Open', 'Copy'],
    );
    expect(viewData.sections.first.items.last.quickActionLabels, isEmpty);
  });
}
