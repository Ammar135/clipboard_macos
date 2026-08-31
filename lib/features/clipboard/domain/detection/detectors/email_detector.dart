import '../../entities/clipboard_capture.dart';
import '../../entities/content_category.dart';
import '../content_detector.dart';
import '../detection_result.dart';

class EmailDetector implements ContentDetector {
  static final _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  int get priority => 70;

  @override
  ContentCategory get category => ContentCategory.email;

  @override
  DetectionResult? detect(ClipboardCapture input) {
    if (input.content is! TextClipboardContent) {
      return null;
    }

    final value = (input.content as TextClipboardContent).value.trim();
    if (!_emailPattern.hasMatch(value)) {
      return null;
    }

    return DetectionResult(
      category: ContentCategory.email,
      metadata: {'email': value},
    );
  }
}
