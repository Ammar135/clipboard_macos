import 'package:clipboard_project/features/clipboard/domain/actions/quick_action_resolver.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/clipboard_item.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/content_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final resolver = QuickActionResolver();

  ClipboardItem item(ContentCategory category, String content) {
    return ClipboardItem(
      id: 1,
      content: content,
      category: category,
      createdAt: DateTime(2026),
      isFavorite: false,
    );
  }

  test('returns open and copy actions for urls', () {
    final actions = resolver.resolve(
      item(ContentCategory.url, 'https://example.com'),
    );

    expect(actions.map((action) => action.label), ['Open', 'Copy']);
  });

  test('returns email actions for emails', () {
    final actions = resolver.resolve(
      item(ContentCategory.email, 'user@example.com'),
    );

    expect(actions.map((action) => action.label), ['Email', 'Copy']);
  });

  test('returns no actions for plain text', () {
    final actions = resolver.resolve(
      item(ContentCategory.text, 'hello'),
    );

    expect(actions, isEmpty);
  });
}
