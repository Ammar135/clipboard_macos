import 'package:clipboard_project/core/database/database.dart';
import 'package:clipboard_project/features/clipboard/data/repositories/clipboard_repository_impl.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/clipboard_item.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/content_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late ClipboardRepositoryImpl repository;

  setUp(() async {
    database = AppDatabase.inMemory();
    repository = ClipboardRepositoryImpl(database);

    await repository.save(
      ClipboardItem(
        id: 0,
        content: 'today item',
        category: ContentCategory.text,
        createdAt: DateTime(2026, 8, 31, 10, 0),
        isFavorite: false,
      ),
    );
    await repository.save(
      ClipboardItem(
        id: 0,
        content: 'yesterday item',
        category: ContentCategory.text,
        createdAt: DateTime(2026, 8, 30, 10, 0),
        isFavorite: false,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('getHistory filters by createdBetween range', () async {
    final items = await repository.getHistory(
      createdBetween: DateTimeRange(
        start: DateTime(2026, 8, 31),
        end: DateTime(2026, 9, 1),
      ),
    );

    expect(items, hasLength(1));
    expect(items.first.content, 'today item');
  });

  test('search combines text and date filters', () async {
    final items = await repository.search(
      'item',
      createdBetween: DateTimeRange(
        start: DateTime(2026, 8, 30),
        end: DateTime(2026, 8, 31),
      ),
    );

    expect(items, hasLength(1));
    expect(items.first.content, 'yesterday item');
  });
}
