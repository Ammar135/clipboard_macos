import '../../../../core/platform/clipboard_platform.dart';
import 'clipboard_quick_action.dart';

class ExecuteQuickAction {
  final ClipboardPlatform _platform;

  const ExecuteQuickAction(this._platform);

  Future<void> call(ClipboardQuickAction action) {
    return switch (action.type) {
      ClipboardQuickActionType.openUrl => _platform.openUrl(action.payload),
      ClipboardQuickActionType.openEmail => _platform.openEmail(action.payload),
      ClipboardQuickActionType.copyText => _platform.copyToClipboard(action.payload),
      ClipboardQuickActionType.copyHex => _platform.copyToClipboard(action.payload),
      ClipboardQuickActionType.previewColor => Future.value(),
    };
  }
}
