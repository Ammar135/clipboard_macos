import '../../entities/clipboard_capture.dart';
import '../../entities/content_category.dart';
import '../content_detector.dart';
import '../detection_result.dart';

class UrlDetector implements ContentDetector {
  static final _urlPattern = RegExp(
    r'^(https?:\/\/|www\.)[^\s]+$',
    caseSensitive: false,
  );

  @override
  int get priority => 80;

  @override
  ContentCategory get category => ContentCategory.url;

  @override
  DetectionResult? detect(ClipboardCapture input) {
    if (input.content is! TextClipboardContent) {
      return null;
    }

    final value = (input.content as TextClipboardContent).value.trim();
    if (!_urlPattern.hasMatch(value)) {
      return null;
    }

    final uri = Uri.tryParse(
      value.startsWith('www.') ? 'https://$value' : value,
    );

    return DetectionResult(
      category: ContentCategory.url,
      metadata: {
        if (uri != null) ...{
          'host': uri.host,
          'scheme': uri.scheme,
        },
      },
    );
  }
}
