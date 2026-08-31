import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/content_category.dart';
import '../../models/clipboard_card_ui_model.dart';
import '../../theme/clipboard_ui_colors.dart';
import '../../theme/clipboard_ui_dimensions.dart';
import '../../theme/clipboard_ui_typography.dart';
import '../content_category_icon.dart';
import 'quick_actions_menu.dart';

class ClipboardItemCard extends StatefulWidget {
  final ClipboardCardUiModel model;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onMoreTap;
  final ValueChanged<String>? onQuickActionTap;

  const ClipboardItemCard({
    super.key,
    required this.model,
    this.onTap,
    this.onFavoriteTap,
    this.onMoreTap,
    this.onQuickActionTap,
  });

  @override
  State<ClipboardItemCard> createState() => _ClipboardItemCardState();
}

class _ClipboardItemCardState extends State<ClipboardItemCard> {
  bool _isHovered = false;

  bool get _showQuickActions =>
      _isHovered || widget.model.isSelected || widget.model.isPinned;

  bool get _showAccentBorder =>
      widget.model.isSelected || widget.model.isPinned;

  @override
  Widget build(BuildContext context) {
    final isGrid = widget.model.layout == ClipboardCardLayout.grid;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(ClipboardUiDimensions.cardPadding),
          decoration: BoxDecoration(
            color: _isHovered
                ? ClipboardUiColors.cardFillHover
                : ClipboardUiColors.cardFill,
            borderRadius:
                BorderRadius.circular(ClipboardUiDimensions.cardRadius),
            border: Border.all(
              color: _showAccentBorder
                  ? ClipboardUiColors.accent
                  : ClipboardUiColors.borderSubtle,
              width: _showAccentBorder ? 1.5 : 1,
            ),
            boxShadow: _showAccentBorder
                ? [
                    BoxShadow(
                      color: ClipboardUiColors.accentGlow,
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: isGrid ? _buildGridContent() : _buildListContent(),
        ),
      ),
    );
  }

  Widget _buildListContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CategoryBadge(category: widget.model.category),
        const SizedBox(width: 10),
        Expanded(child: _buildTextColumn()),
        if (widget.model.isPinned)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 1),
            child: GestureDetector(
              onTap: widget.onFavoriteTap,
              child: const Icon(
                CupertinoIcons.star_fill,
                size: 12,
                color: Color(0xFFFFB340),
              ),
            ),
          ),
        _MoreButton(onTap: widget.onMoreTap),
        if (_showQuickActions) ...[
          const SizedBox(width: 8),
          QuickActionsMenu(onActionTap: widget.onQuickActionTap),
        ],
      ],
    );
  }

  Widget _buildGridContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _CategoryBadge(category: widget.model.category, compact: true),
            const Spacer(),
            _MoreButton(onTap: widget.onMoreTap),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildGridBody()),
        const SizedBox(height: 8),
        Text(
          widget.model.metaLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ClipboardUiTypography.cardMeta(),
        ),
      ],
    );
  }

  Widget _buildGridBody() {
    return switch (widget.model.category) {
      ContentCategory.color => _ColorSwatch(hex: widget.model.colorHex),
      ContentCategory.image => _ImagePreview(path: widget.model.imagePath),
      _ => Text(
          widget.model.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: ClipboardUiTypography.cardTitle(),
        ),
    };
  }

  Widget _buildTextColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.model.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: ClipboardUiTypography.cardTitle(
            isSelected: widget.model.isSelected,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.model.metaLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ClipboardUiTypography.cardMeta(),
        ),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final ContentCategory category;
  final bool compact;

  const _CategoryBadge({
    required this.category,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 22 : 24,
      height: compact ? 22 : 24,
      decoration: BoxDecoration(
        color: ClipboardUiColors.chipInactiveFill,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ClipboardUiColors.borderSubtle),
      ),
      child: Icon(
        ContentCategoryIcon.iconFor(category),
        size: compact ? 12 : 13,
        color: ClipboardUiColors.textSecondary,
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _MoreButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: const Padding(
          padding: EdgeInsets.all(2),
          child: Icon(
            CupertinoIcons.ellipsis,
            size: 14,
            color: ClipboardUiColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String? hex;

  const _ColorSwatch({this.hex});

  @override
  Widget build(BuildContext context) {
    final color = _parseHex(hex) ?? const Color(0xFFFF5733);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hex ?? '#FF5733',
          style: ClipboardUiTypography.cardTitle(),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: ClipboardUiColors.borderSubtle),
            ),
          ),
        ),
      ],
    );
  }

  Color? _parseHex(String? value) {
    if (value == null || !value.startsWith('#')) return null;
    final hex = value.substring(1);
    if (hex.length == 6) {
      return Color(0xFF000000 | int.parse(hex, radix: 16));
    }
    return null;
  }
}

class _ImagePreview extends StatelessWidget {
  final String? path;

  const _ImagePreview({this.path});

  @override
  Widget build(BuildContext context) {
    final file = path == null ? null : File(path!);
    final hasFile = file != null && file.existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: ClipboardUiColors.borderSubtle),
          color: ClipboardUiColors.chipInactiveFill,
        ),
        child: hasFile
            ? Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A6741),
            Color(0xFF8B7355),
            Color(0xFF5C7A8A),
          ],
        ),
      ),
      child: Icon(
        CupertinoIcons.photo,
        size: 20,
        color: Colors.white.withValues(alpha: 0.85),
      ),
    );
  }
}
