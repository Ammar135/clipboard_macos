import 'package:flutter/material.dart';

import '../../domain/entities/clipboard_date_filter.dart';

class DateFilterButton extends StatelessWidget {
  final ClipboardDateFilter currentFilter;
  final ValueChanged<ClipboardDateFilter> onFilterChanged;

  const DateFilterButton({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = currentFilter.isActive;

    return PopupMenuButton<_DateFilterMenuAction>(
      tooltip: 'Filter by date',
      icon: Icon(
        isActive ? Icons.filter_list : Icons.filter_list_outlined,
        color: isActive ? theme.colorScheme.primary : null,
      ),
      onSelected: (action) => _handleSelection(context, action),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _DateFilterMenuAction.allDates,
          child: Text('All dates'),
        ),
        PopupMenuItem(
          value: _DateFilterMenuAction.today,
          child: Text('Today'),
        ),
        PopupMenuItem(
          value: _DateFilterMenuAction.yesterday,
          child: Text('Yesterday'),
        ),
        PopupMenuItem(
          value: _DateFilterMenuAction.last7Days,
          child: Text('Last 7 days'),
        ),
        PopupMenuItem(
          value: _DateFilterMenuAction.pickDate,
          child: Text('Pick a date...'),
        ),
      ],
    );
  }

  Future<void> _handleSelection(
    BuildContext context,
    _DateFilterMenuAction action,
  ) async {
    switch (action) {
      case _DateFilterMenuAction.allDates:
        onFilterChanged(const ClipboardDateFilterNone());
      case _DateFilterMenuAction.today:
        onFilterChanged(
          const ClipboardDateFilterPreset(ClipboardDateFilterPresetType.today),
        );
      case _DateFilterMenuAction.yesterday:
        onFilterChanged(
          const ClipboardDateFilterPreset(ClipboardDateFilterPresetType.yesterday),
        );
      case _DateFilterMenuAction.last7Days:
        onFilterChanged(
          const ClipboardDateFilterPreset(ClipboardDateFilterPresetType.last7Days),
        );
      case _DateFilterMenuAction.pickDate:
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

enum _DateFilterMenuAction {
  allDates,
  today,
  yesterday,
  last7Days,
  pickDate,
}
