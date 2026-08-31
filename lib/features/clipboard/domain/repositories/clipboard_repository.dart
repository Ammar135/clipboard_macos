import 'package:flutter/material.dart';

import '../entities/clipboard_item.dart';

abstract interface class ClipboardRepository {
  Future<List<ClipboardItem>> getHistory({
    int limit = 1000,
    DateTimeRange? createdBetween,
  });

  Future<List<ClipboardItem>> search(
    String query, {
    int limit = 1000,
    DateTimeRange? createdBetween,
  });

  Future<void> save(ClipboardItem item);

  Future<void> delete(int id);

  Future<void> clear();

  Future<void> toggleFavorite(int id);

  Future<void> enforceHistoryLimit(int limit);

  Future<ClipboardItem?> findByContentHash(String hash);

  Future<void> touchLastUsed(int id);
}
