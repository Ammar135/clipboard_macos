import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/actions/clipboard_quick_action.dart';
import '../../domain/actions/execute_quick_action.dart';
import '../../domain/actions/quick_action_resolver.dart';
import '../../domain/entities/clipboard_item.dart';
import '../../domain/entities/content_category.dart';
import '../utils/clipboard_timestamp_formatter.dart';
import 'content_category_icon.dart';

class ClipboardItemTile extends StatelessWidget {
  final ClipboardItem item;
  final VoidCallback onSelect;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;
  final bool isSelected;

  const ClipboardItemTile({
    super.key,
    required this.item,
    required this.onSelect,
    required this.onToggleFavorite,
    required this.onDelete,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quickActions = context.read<QuickActionResolver>().resolve(item);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelect,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 10),
                child: Tooltip(
                  message: ContentCategoryIcon.labelFor(item.category),
                  child: Icon(
                    ContentCategoryIcon.iconFor(item.category),
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.isImage)
                      Image.file(
                        File(item.content),
                        height: 80,
                        fit: BoxFit.contain,
                      )
                    else if (item.category == ContentCategory.color)
                      _ColorPreview(content: item.content)
                    else
                      Text(
                        item.content.replaceAll('\n', ' ↵ '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected 
                              ? theme.colorScheme.onPrimaryContainer 
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      item.sourceApp ?? 'Unknown App',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Tooltip(
                      message: ClipboardTimestampFormatter.tooltipForItem(
                        createdAt: item.createdAt,
                        lastUsedAt: item.lastUsedAt,
                        locale: Localizations.localeOf(context),
                      ),
                      child: Text(
                        ClipboardTimestampFormatter.formatCopiedAt(
                          item.createdAt,
                          Localizations.localeOf(context),
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (quickActions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: quickActions
                            .map((action) => _QuickActionChip(
                                  action: action,
                                  onPressed: () => _runQuickAction(context, action),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      item.isFavorite ? Icons.star : Icons.star_border,
                      size: 18,
                      color: item.isFavorite 
                          ? Colors.orange 
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: onToggleFavorite,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runQuickAction(
    BuildContext context,
    ClipboardQuickAction action,
  ) async {
    await context.read<ExecuteQuickAction>().call(action);
  }
}

class _QuickActionChip extends StatelessWidget {
  final ClipboardQuickAction action;
  final VoidCallback onPressed;

  const _QuickActionChip({
    required this.action,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(action.label),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _ColorPreview extends StatelessWidget {
  final String content;

  const _ColorPreview({required this.content});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(content);
    return Row(
      children: [
        if (color != null)
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        Expanded(
          child: Text(
            content,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Color? _parseColor(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('#')) {
      final hex = trimmed.substring(1);
      if (hex.length == 3) {
        final r = int.parse('${hex[0]}${hex[0]}', radix: 16);
        final g = int.parse('${hex[1]}${hex[1]}', radix: 16);
        final b = int.parse('${hex[2]}${hex[2]}', radix: 16);
        return Color.fromARGB(255, r, g, b);
      }
      if (hex.length == 6) {
        final value = int.parse(hex, radix: 16);
        return Color(0xFF000000 | value);
      }
    }
    return null;
  }
}
