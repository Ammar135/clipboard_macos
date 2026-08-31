import '../entities/clipboard_capture.dart';
import '../entities/content_category.dart';
import 'detection_result.dart';

abstract interface class ContentDetector {
  int get priority;

  ContentCategory get category;

  DetectionResult? detect(ClipboardCapture input);
}
