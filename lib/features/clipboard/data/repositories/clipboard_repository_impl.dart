import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';
import '../../domain/entities/clipboard_item.dart';
import '../../domain/entities/content_category.dart';
import '../../domain/repositories/clipboard_repository.dart';

class ClipboardRepositoryImpl implements ClipboardRepository {
  final AppDatabase _db;

  ClipboardRepositoryImpl(this._db);

  @override
  Future<List<ClipboardItem>> getHistory({
    int limit = 1000,
    DateTimeRange? createdBetween,
  }) async {
    final query = _db.select(_db.clipboardItemsTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.isFavorite, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    _applyDateFilter(query, createdBetween);

    final results = await query.get();
    return results.map(_mapEntityToDomain).toList();
  }

  @override
  Future<List<ClipboardItem>> search(
    String query, {
    int limit = 1000,
    DateTimeRange? createdBetween,
  }) async {
    final likeQuery = '%$query%';
    final dbQuery = _db.select(_db.clipboardItemsTable)
      ..where((t) => t.content.like(likeQuery))
      ..orderBy([
        (t) => OrderingTerm(expression: t.isFavorite, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    _applyDateFilter(dbQuery, createdBetween);

    final results = await dbQuery.get();
    return results.map(_mapEntityToDomain).toList();
  }

  void _applyDateFilter(
    SimpleSelectStatement<$ClipboardItemsTableTable, ClipboardItemEntity> query,
    DateTimeRange? createdBetween,
  ) {
    if (createdBetween == null) {
      return;
    }

    final startMs = createdBetween.start.millisecondsSinceEpoch;
    final endMs = createdBetween.end.millisecondsSinceEpoch;

    query.where((t) => t.createdAt.isBiggerOrEqualValue(startMs));
    query.where((t) => t.createdAt.isSmallerThanValue(endMs));
  }

  @override
  Future<void> save(ClipboardItem item) async {
    await _db.into(_db.clipboardItemsTable).insert(
          ClipboardItemsTableCompanion.insert(
            content: item.content,
            type: Value(item.category.storageValue),
            contentHash: Value(item.contentHash),
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
    final query = _db.select(_db.clipboardItemsTable)
      ..where((t) => t.isFavorite.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(1, offset: limit);

    final boundaryItem = await query.getSingleOrNull();

    if (boundaryItem != null) {
      await (_db.delete(_db.clipboardItemsTable)
            ..where((t) => t.isFavorite.equals(false))
            ..where(
              (t) => t.createdAt.isSmallerOrEqualValue(boundaryItem.createdAt),
            ))
          .go();
    }
  }

  @override
  Future<ClipboardItem?> findByContentHash(String hash) async {
    final query = _db.select(_db.clipboardItemsTable)
      ..where((t) => t.contentHash.equals(hash))
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result == null ? null : _mapEntityToDomain(result);
  }

  @override
  Future<void> touchLastUsed(int id) async {
    await (_db.update(_db.clipboardItemsTable)..where((t) => t.id.equals(id)))
        .write(
      ClipboardItemsTableCompanion(
        lastUsedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  ClipboardItem _mapEntityToDomain(ClipboardItemEntity entity) {
    return ClipboardItem(
      id: entity.id,
      content: entity.content,
      category: ContentCategory.fromStorage(entity.type),
      contentHash: entity.contentHash,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAt),
      lastUsedAt: entity.lastUsedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(entity.lastUsedAt!)
          : null,
      sourceApp: entity.sourceApp,
      isFavorite: entity.isFavorite,
    );
  }
}
