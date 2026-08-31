import '../entities/clipboard_item.dart';
import '../entities/content_category.dart';
import 'clipboard_quick_action.dart';

class QuickActionResolver {
  List<ClipboardQuickAction> resolve(ClipboardItem item) {
    return switch (item.category) {
      ContentCategory.url => [
        ClipboardQuickAction(
          type: ClipboardQuickActionType.openUrl,
          label: 'Open',
          payload: item.content,
        ),
        ClipboardQuickAction(
          type: ClipboardQuickActionType.copyText,
          label: 'Copy',
          payload: item.content,
        ),
      ],
      ContentCategory.email => [
        ClipboardQuickAction(
          type: ClipboardQuickActionType.openEmail,
          label: 'Email',
          payload: item.content,
        ),
        ClipboardQuickAction(
          type: ClipboardQuickActionType.copyText,
          label: 'Copy',
          payload: item.content,
        ),
      ],
      ContentCategory.phone => [
        ClipboardQuickAction(
          type: ClipboardQuickActionType.copyText,
          label: 'Copy',
          payload: item.content,
        ),
      ],
      ContentCategory.code => [
        ClipboardQuickAction(
          type: ClipboardQuickActionType.copyText,
          label: 'Copy',
          payload: item.content,
        ),
      ],
      _ => const [],
    };
  }
}
