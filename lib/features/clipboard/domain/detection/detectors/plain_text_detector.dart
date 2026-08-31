import '../../entities/clipboard_capture.dart';
import '../../entities/content_category.dart';
import '../content_detector.dart';
import '../detection_result.dart';

class PlainTextDetector implements ContentDetector {
  @override
  int get priority => 0;

  @override
  ContentCategory get category => ContentCategory.text;

  @override
  DetectionResult? detect(ClipboardCapture input) {
    if (input.content is TextClipboardContent) {
      return const DetectionResult(category: ContentCategory.text);
    }
    return null;
  }
}
