import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClipboardTimestampFormatter {
  static String formatCopiedAt(DateTime dateTime, Locale locale) {
    final date = DateFormat.yMMMd(locale.toString()).format(dateTime);
    final time = DateFormat.jm(locale.toString()).format(dateTime);
    return '$date · $time';
  }

  static String formatFull(DateTime dateTime, Locale locale) {
    return DateFormat.yMMMd(locale.toString()).add_jms().format(dateTime);
  }

  static String tooltipForItem({
    required DateTime createdAt,
    required DateTime? lastUsedAt,
    required Locale locale,
  }) {
    final copied = 'Copied: ${formatFull(createdAt, locale)}';
    if (lastUsedAt == null || lastUsedAt.isAtSameMomentAs(createdAt)) {
      return copied;
    }

    return '$copied · Last used: ${formatFull(lastUsedAt, locale)}';
  }
}
