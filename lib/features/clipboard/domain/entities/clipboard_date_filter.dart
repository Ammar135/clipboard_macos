import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ClipboardDateFilterPresetType {
  today,
  yesterday,
  last7Days,
}

sealed class ClipboardDateFilter extends Equatable {
  const ClipboardDateFilter();

  bool get isActive => this is! ClipboardDateFilterNone;

  DateTimeRange? toRange({DateTime? now}) {
    final reference = now ?? DateTime.now();
    return switch (this) {
      ClipboardDateFilterNone() => null,
      ClipboardDateFilterPreset(:final type) => _rangeForPreset(type, reference),
      ClipboardDateFilterDay(:final day) => _dayRange(day),
    };
  }

  static DateTimeRange _dayRange(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return DateTimeRange(start: start, end: end);
  }

  static DateTimeRange _rangeForPreset(
    ClipboardDateFilterPresetType type,
    DateTime now,
  ) {
    final todayStart = DateTime(now.year, now.month, now.day);

    return switch (type) {
      ClipboardDateFilterPresetType.today => DateTimeRange(
          start: todayStart,
          end: todayStart.add(const Duration(days: 1)),
        ),
      ClipboardDateFilterPresetType.yesterday => DateTimeRange(
          start: todayStart.subtract(const Duration(days: 1)),
          end: todayStart,
        ),
      ClipboardDateFilterPresetType.last7Days => DateTimeRange(
          start: todayStart.subtract(const Duration(days: 6)),
          end: todayStart.add(const Duration(days: 1)),
        ),
    };
  }
}

final class ClipboardDateFilterNone extends ClipboardDateFilter {
  const ClipboardDateFilterNone();

  @override
  List<Object?> get props => const [];
}

final class ClipboardDateFilterPreset extends ClipboardDateFilter {
  final ClipboardDateFilterPresetType type;

  const ClipboardDateFilterPreset(this.type);

  @override
  List<Object?> get props => [type];
}

final class ClipboardDateFilterDay extends ClipboardDateFilter {
  final DateTime day;

  const ClipboardDateFilterDay(this.day);

  @override
  List<Object?> get props => [day.year, day.month, day.day];
}
