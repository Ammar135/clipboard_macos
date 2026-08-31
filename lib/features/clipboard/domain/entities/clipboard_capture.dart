sealed class ClipboardContent {
  const ClipboardContent();
}

final class TextClipboardContent extends ClipboardContent {
  final String value;

  const TextClipboardContent(this.value);
}

/// Path to PNG on disk (matches current Swift monitor).
final class ImageClipboardContent extends ClipboardContent {
  final String path;

  const ImageClipboardContent(this.path);
}

class ClipboardCapture {
  final ClipboardContent content;
  final DateTime capturedAt;
  final String? sourceApp;

  const ClipboardCapture({
    required this.content,
    required this.capturedAt,
    this.sourceApp,
  });

  factory ClipboardCapture.fromPlatformEvent({
    required String content,
    required String platformType,
    String? sourceApp,
    DateTime? capturedAt,
  }) {
    final ClipboardContent clipboardContent;
    if (platformType == 'image') {
      clipboardContent = ImageClipboardContent(content);
    } else {
      clipboardContent = TextClipboardContent(content);
    }

    return ClipboardCapture(
      content: clipboardContent,
      capturedAt: capturedAt ?? DateTime.now(),
      sourceApp: sourceApp,
    );
  }
}
