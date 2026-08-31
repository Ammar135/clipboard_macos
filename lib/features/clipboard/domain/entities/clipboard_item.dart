import 'package:equatable/equatable.dart';

import 'content_category.dart';

class ClipboardItem extends Equatable {
  final int id;
  final String content;
  final ContentCategory category;
  final String? contentHash;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final String? sourceApp;
  final bool isFavorite;

  const ClipboardItem({
    required this.id,
    required this.content,
    required this.category,
    this.contentHash,
    required this.createdAt,
    this.lastUsedAt,
    this.sourceApp,
    required this.isFavorite,
  });

  String get type => category.storageValue;

  bool get isImage => category == ContentCategory.image;

  @override
  List<Object?> get props => [
        id,
        content,
        category,
        contentHash,
        createdAt,
        lastUsedAt,
        sourceApp,
        isFavorite,
      ];

  ClipboardItem copyWith({
    int? id,
    String? content,
    ContentCategory? category,
    String? contentHash,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    String? sourceApp,
    bool? isFavorite,
  }) {
    return ClipboardItem(
      id: id ?? this.id,
      content: content ?? this.content,
      category: category ?? this.category,
      contentHash: contentHash ?? this.contentHash,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      sourceApp: sourceApp ?? this.sourceApp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
