import 'package:clipboard_project/features/clipboard/presentation/utils/clipboard_timestamp_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  test('formatCopiedAt returns non-empty localized string', () {
    final formatted = ClipboardTimestampFormatter.formatCopiedAt(
      DateTime(2026, 8, 31, 9, 15),
      const Locale('en'),
    );

    expect(formatted, isNotEmpty);
    expect(formatted.contains('·'), isTrue);
  });

  test('tooltip includes copied and last used timestamps', () {
    final createdAt = DateTime(2026, 8, 31, 9, 0);
    final lastUsedAt = DateTime(2026, 8, 31, 10, 0);

    final tooltip = ClipboardTimestampFormatter.tooltipForItem(
      createdAt: createdAt,
      lastUsedAt: lastUsedAt,
      locale: const Locale('en'),
    );

    expect(tooltip.contains('Copied:'), isTrue);
    expect(tooltip.contains('Last used:'), isTrue);
  });
}
