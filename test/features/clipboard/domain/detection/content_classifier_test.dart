import 'package:clipboard_project/features/clipboard/domain/detection/content_classifier.dart';
import 'package:clipboard_project/features/clipboard/domain/detection/detectors/code_detector.dart';
import 'package:clipboard_project/features/clipboard/domain/detection/detectors/color_detector.dart';
import 'package:clipboard_project/features/clipboard/domain/detection/detectors/email_detector.dart';
import 'package:clipboard_project/features/clipboard/domain/detection/detectors/image_detector.dart';
import 'package:clipboard_project/features/clipboard/domain/detection/detectors/phone_detector.dart';
import 'package:clipboard_project/features/clipboard/domain/detection/detectors/plain_text_detector.dart';
import 'package:clipboard_project/features/clipboard/domain/detection/detectors/url_detector.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/clipboard_capture.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/content_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ContentClassifier classifier;

  setUp(() {
    classifier = ContentClassifier([
      ImageDetector(),
      UrlDetector(),
      EmailDetector(),
      PhoneDetector(),
      ColorDetector(),
      CodeDetector(),
      PlainTextDetector(),
    ]);
  });

  ClipboardCapture captureText(String value) {
    return ClipboardCapture(
      content: TextClipboardContent(value),
      capturedAt: DateTime(2026),
    );
  }

  ClipboardCapture captureImage(String path) {
    return ClipboardCapture(
      content: ImageClipboardContent(path),
      capturedAt: DateTime(2026),
    );
  }

  test('classifies image captures as image', () {
    final result = classifier.classify(captureImage('/tmp/a.png'));
    expect(result.category, ContentCategory.image);
  });

  test('classifies plain text as text', () {
    final result = classifier.classify(captureText('hello world'));
    expect(result.category, ContentCategory.text);
  });

  test('prioritizes url over text', () {
    final result = classifier.classify(captureText('https://example.com'));
    expect(result.category, ContentCategory.url);
  });

  test('falls back to text when no detector matches', () {
    final classifierWithoutPlain = ContentClassifier([
      UrlDetector(),
      EmailDetector(),
    ]);

    final result = classifierWithoutPlain.classify(captureText('hello'));
    expect(result.category, ContentCategory.text);
  });
}
