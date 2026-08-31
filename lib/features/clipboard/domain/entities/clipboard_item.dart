import 'package:equatable/equatable.dart';

class ClipboardItem extends Equatable {
  final int id;
  final String content;
  final String type;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final String? sourceApp;
  final bool isFavorite;

  const ClipboardItem({
    required this.id,
    required this.content,
    required this.type,
    required this.createdAt,
    this.lastUsedAt,
    this.sourceApp,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        type,
        createdAt,
        lastUsedAt,
        sourceApp,
        isFavorite,
      ];
      
  ClipboardItem copyWith({
    int? id,
    String? content,
    String? type,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    String? sourceApp,
    bool? isFavorite,
  }) {
    return ClipboardItem(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      sourceApp: sourceApp ?? this.sourceApp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
