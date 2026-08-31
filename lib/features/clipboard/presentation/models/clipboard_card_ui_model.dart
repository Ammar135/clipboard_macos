import 'package:equatable/equatable.dart';

import '../../domain/entities/content_category.dart';

enum ClipboardCardLayout {
  list,
  grid,
}

class ClipboardCardUiModel extends Equatable {
  final int itemId;
  final String content;
  final ContentCategory category;
  final String title;
  final String sourceApp;
  final String timestampLabel;
  final bool isPinned;
  final bool isSelected;
  final ClipboardCardLayout layout;
  final String? colorHex;
  final String? imagePath;
  final List<String> quickActionLabels;

  const ClipboardCardUiModel({
    required this.itemId,
    required this.content,
    required this.category,
    required this.title,
    required this.sourceApp,
    required this.timestampLabel,
    this.isPinned = false,
    this.isSelected = false,
    this.layout = ClipboardCardLayout.list,
    this.colorHex,
    this.imagePath,
    this.quickActionLabels = const [],
  });

  String get metaLabel => '$sourceApp · $timestampLabel';

  @override
  List<Object?> get props => [
        itemId,
        content,
        category,
        title,
        sourceApp,
        timestampLabel,
        isPinned,
        isSelected,
        layout,
        colorHex,
        imagePath,
        quickActionLabels,
      ];
}

class ClipboardCategoryChipUiModel extends Equatable {
  final ContentCategory? category;
  final String label;
  final bool isActive;

  const ClipboardCategoryChipUiModel({
    required this.label,
    this.category,
    this.isActive = false,
  });

  @override
  List<Object?> get props => [category, label, isActive];
}

class ClipboardPanelSectionUiModel extends Equatable {
  final String label;
  final List<ClipboardCardUiModel> items;

  const ClipboardPanelSectionUiModel({
    required this.label,
    this.items = const [],
  });

  int get itemCount => items.length;

  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [label, items];
}

class ClipboardPanelViewData extends Equatable {
  final List<ClipboardCategoryChipUiModel> categoryChips;
  final ClipboardPanelSectionUiModel pinnedSection;
  final List<ClipboardPanelSectionUiModel> sections;
  final int totalItemCount;

  const ClipboardPanelViewData({
    required this.categoryChips,
    required this.pinnedSection,
    required this.sections,
    required this.totalItemCount,
  });

  bool get isEmpty => pinnedSection.isEmpty && sections.every((s) => s.isEmpty);

  @override
  List<Object?> get props => [categoryChips, pinnedSection, sections, totalItemCount];
}
