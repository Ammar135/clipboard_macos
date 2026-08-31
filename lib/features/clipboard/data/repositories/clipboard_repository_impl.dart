import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/clipboard_item.dart';
import '../../domain/repositories/clipboard_repository.dart';

class ClipboardRepositoryImpl implements ClipboardRepository {
  final AppDatabase _db;

  ClipboardRepositoryImpl(this._db);

  @override
  Future<List<ClipboardItem>> getHistory({int limit = 1000}) async {
    final query = _db.select(_db.clipboardItemsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.isFavorite, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    final results = await query.get();
    return results.map(_mapEntityToDomain).toList();
  }

  @override
  Future<List<ClipboardItem>> search(String query, {int limit = 1000}) async {
    final likeQuery = '%$query%';
    final dbQuery = _db.select(_db.clipboardItemsTable)
      ..where((t) => t.content.like(likeQuery))
      ..orderBy([
        (t) => OrderingTerm(expression: t.isFavorite, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    final results = await dbQuery.get();
    return results.map(_mapEntityToDomain).toList();
  }

  @override
  Future<void> save(ClipboardItem item) async {
    await _db
        .into(_db.clipboardItemsTable)
        .insert(
          ClipboardItemsTableCompanion.insert(
            content: item.content,
            type: Value(item.type),
            createdAt: item.createdAt.millisecondsSinceEpoch,
            lastUsedAt: Value(item.lastUsedAt?.millisecondsSinceEpoch),
            sourceApp: Value(item.sourceApp),
            isFavorite: Value(item.isFavorite),
          ),
        );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(
      _db.clipboardItemsTable,
    )..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> clear() async {
    await _db.delete(_db.clipboardItemsTable).go();
  }

  @override
  Future<void> toggleFavorite(int id) async {
    final query = _db.select(_db.clipboardItemsTable)
      ..where((t) => t.id.equals(id));
    final item = await query.getSingleOrNull();
    if (item != null) {
      await (_db.update(
        _db.clipboardItemsTable,
      )..where((t) => t.id.equals(id))).write(
        ClipboardItemsTableCompanion(isFavorite: Value(!item.isFavorite)),
      );
    }
  }

  @override
  Future<void> enforceHistoryLimit(int limit) async {
    // Keep favorites, only delete non-favorites that exceed the limit

    // First, find the created_at timestamp of the item at the limit boundary
    // among non-favorites
    final query = _db.select(_db.clipboardItemsTable)
      ..where((t) => t.isFavorite.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(1, offset: limit);

    final boundaryItem = await query.getSingleOrNull();

    if (boundaryItem != null) {
      // Delete all non-favorites older than or equal to the boundary item
      await (_db.delete(_db.clipboardItemsTable)
            ..where((t) => t.isFavorite.equals(false))
            ..where(
              (t) => t.createdAt.isSmallerOrEqualValue(boundaryItem.createdAt),
            ))
          .go();
    }
  }

  ClipboardItem _mapEntityToDomain(ClipboardItemEntity entity) {
    return ClipboardItem(
      id: entity.id,
      content: entity.content,
      type: entity.type,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAt),
      lastUsedAt: entity.lastUsedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(entity.lastUsedAt!)
          : null,
      sourceApp: entity.sourceApp,
      isFavorite: entity.isFavorite,
    );
  }
}
