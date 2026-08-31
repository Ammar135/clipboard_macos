enum ClipboardQuickActionType {
  openUrl,
  openEmail,
  copyText,
  copyHex,
  previewColor,
}

class ClipboardQuickAction {
  final ClipboardQuickActionType type;
  final String label;
  final String payload;

  const ClipboardQuickAction({
    required this.type,
    required this.label,
    required this.payload,
  });
}
