import '../../entities/clipboard_capture.dart';
import '../../entities/content_category.dart';
import '../content_detector.dart';
import '../detection_result.dart';

class ImageDetector implements ContentDetector {
  @override
  int get priority => 100;

  @override
  ContentCategory get category => ContentCategory.image;

  @override
  DetectionResult? detect(ClipboardCapture input) {
    if (input.content is ImageClipboardContent) {
      return const DetectionResult(category: ContentCategory.image);
    }
    return null;
  }
}
