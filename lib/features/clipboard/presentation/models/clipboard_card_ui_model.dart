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
  final List<ClipboardCardUiModel> listItems;
  final List<ClipboardCardUiModel> gridItems;

  const ClipboardPanelSectionUiModel({
    required this.label,
    this.listItems = const [],
    this.gridItems = const [],
  });

  int get itemCount => listItems.length + gridItems.length;

  bool get isEmpty => itemCount == 0;

  @override
  List<Object?> get props => [label, listItems, gridItems];
}

class ClipboardPanelViewData extends Equatable {
  final List<ClipboardCategoryChipUiModel> categoryChips;
  final List<ClipboardCardUiModel> pinnedItems;
  final List<ClipboardPanelSectionUiModel> sections;
  final int totalItemCount;

  const ClipboardPanelViewData({
    required this.categoryChips,
    required this.pinnedItems,
    required this.sections,
    required this.totalItemCount,
  });

  bool get isEmpty => pinnedItems.isEmpty && sections.every((s) => s.isEmpty);

  @override
  List<Object?> get props => [categoryChips, pinnedItems, sections, totalItemCount];
}
