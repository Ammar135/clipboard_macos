import '../entities/clipboard_capture.dart';
import '../entities/content_category.dart';
import 'content_detector.dart';
import 'detection_result.dart';

class ContentClassifier {
  ContentClassifier(List<ContentDetector> detectors)
      : _detectors = List.of(detectors)
          ..sort((a, b) => b.priority.compareTo(a.priority));

  final List<ContentDetector> _detectors;

  DetectionResult classify(ClipboardCapture input) {
    for (final detector in _detectors) {
      final result = detector.detect(input);
      if (result != null) {
        return result;
      }
    }

    return const DetectionResult(category: ContentCategory.text);
  }
}
