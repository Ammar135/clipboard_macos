import 'package:clipboard_project/features/clipboard/domain/entities/clipboard_date_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final reference = DateTime(2026, 8, 31, 15, 30);

  test('none filter returns null range', () {
    expect(
      const ClipboardDateFilterNone().toRange(now: reference),
      isNull,
    );
  });

  test('today filter covers current calendar day', () {
    final range = const ClipboardDateFilterPreset(
      ClipboardDateFilterPresetType.today,
    ).toRange(now: reference);

    expect(range!.start, DateTime(2026, 8, 31));
    expect(range.end, DateTime(2026, 9, 1));
  });

  test('yesterday filter covers previous calendar day', () {
    final range = const ClipboardDateFilterPreset(
      ClipboardDateFilterPresetType.yesterday,
    ).toRange(now: reference);

    expect(range!.start, DateTime(2026, 8, 30));
    expect(range.end, DateTime(2026, 8, 31));
  });

  test('last7Days filter covers seven calendar days including today', () {
    final range = const ClipboardDateFilterPreset(
      ClipboardDateFilterPresetType.last7Days,
    ).toRange(now: reference);

    expect(range!.start, DateTime(2026, 8, 25));
    expect(range.end, DateTime(2026, 9, 1));
  });

  test('day filter covers selected calendar day', () {
    final range = ClipboardDateFilterDay(
      DateTime(2026, 8, 10, 23, 59),
    ).toRange(now: reference);

    expect(range!.start, DateTime(2026, 8, 10));
    expect(range.end, DateTime(2026, 8, 11));
  });
}
