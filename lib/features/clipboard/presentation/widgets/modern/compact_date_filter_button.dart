import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/clipboard_date_filter.dart';
import '../../theme/clipboard_ui_colors.dart';

class CompactDateFilterButton extends StatelessWidget {
  final ClipboardDateFilter currentFilter;
  final ValueChanged<ClipboardDateFilter> onFilterChanged;

  const CompactDateFilterButton({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentFilter.isActive;

    return PopupMenuButton<DateFilterMenuAction>(
      tooltip: 'Filter by date',
      padding: EdgeInsets.zero,
      offset: const Offset(0, 28),
      onSelected: (action) => _handleSelection(context, action),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: DateFilterMenuAction.allDates,
          child: Text('All dates'),
        ),
        PopupMenuItem(
          value: DateFilterMenuAction.today,
          child: Text('Today'),
        ),
        PopupMenuItem(
          value: DateFilterMenuAction.yesterday,
          child: Text('Yesterday'),
        ),
        PopupMenuItem(
          value: DateFilterMenuAction.last7Days,
          child: Text('Last 7 days'),
        ),
        PopupMenuItem(
          value: DateFilterMenuAction.pickDate,
          child: Text('Pick a date...'),
        ),
      ],
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: isActive
            ? BoxDecoration(
                color: ClipboardUiColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              )
            : null,
        child: Icon(
          CupertinoIcons.calendar,
          size: 15,
          color: isActive
              ? ClipboardUiColors.accent
              : ClipboardUiColors.textSecondary,
        ),
      ),
    );
  }

  Future<void> _handleSelection(
    BuildContext context,
    DateFilterMenuAction action,
  ) async {
    switch (action) {
      case DateFilterMenuAction.allDates:
        onFilterChanged(const ClipboardDateFilterNone());
      case DateFilterMenuAction.today:
        onFilterChanged(
          const ClipboardDateFilterPreset(ClipboardDateFilterPresetType.today),
        );
      case DateFilterMenuAction.yesterday:
        onFilterChanged(
          const ClipboardDateFilterPreset(ClipboardDateFilterPresetType.yesterday),
        );
      case DateFilterMenuAction.last7Days:
        onFilterChanged(
          const ClipboardDateFilterPreset(ClipboardDateFilterPresetType.last7Days),
        );
      case DateFilterMenuAction.pickDate:
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null && context.mounted) {
          onFilterChanged(ClipboardDateFilterDay(picked));
        }
    }
  }
}

enum DateFilterMenuAction {
  allDates,
  today,
  yesterday,
  last7Days,
  pickDate,
}
