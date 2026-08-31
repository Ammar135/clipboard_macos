import 'package:clipboard_project/features/clipboard/domain/detection/detectors/code_detector.dart';
import 'package:clipboard_project/features/clipboard/domain/detection/detectors/color_detector.dart';
import 'package:clipboard_project/features/clipboard/domain/detection/detectors/email_detector.dart';
import 'package:clipboard_project/features/clipboard/domain/detection/detectors/phone_detector.dart';
import 'package:clipboard_project/features/clipboard/domain/detection/detectors/url_detector.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/clipboard_capture.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/content_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ClipboardCapture capture(String value) {
    return ClipboardCapture(
      content: TextClipboardContent(value),
      capturedAt: DateTime(2026),
    );
  }

  group('UrlDetector', () {
    final detector = UrlDetector();

    test('detects https urls', () {
      final result = detector.detect(capture('https://example.com'));
      expect(result?.category, ContentCategory.url);
    });

    test('rejects invalid urls', () {
      expect(detector.detect(capture('not a url')), isNull);
    });
  });

  group('EmailDetector', () {
    final detector = EmailDetector();

    test('detects valid email', () {
      final result = detector.detect(capture('user@example.com'));
      expect(result?.category, ContentCategory.email);
    });

    test('rejects text with at sign', () {
      expect(detector.detect(capture('hello@there')), isNull);
    });
  });

  group('PhoneDetector', () {
    final detector = PhoneDetector();

    test('detects international phone', () {
      final result = detector.detect(capture('+20 100 123 4567'));
      expect(result?.category, ContentCategory.phone);
    });

    test('rejects short numeric strings', () {
      expect(detector.detect(capture('123456')), isNull);
    });
  });

  group('ColorDetector', () {
    final detector = ColorDetector();

    test('detects hex colors', () {
      final result = detector.detect(capture('#FF5733'));
      expect(result?.category, ContentCategory.color);
      expect(result?.metadata['hex'], '#FF5733');
    });

    test('detects rgb colors', () {
      final result = detector.detect(capture('rgb(255, 87, 51)'));
      expect(result?.category, ContentCategory.color);
    });
  });

  group('CodeDetector', () {
    final detector = CodeDetector();

    test('detects json', () {
      final result = detector.detect(capture('{"a":1}'));
      expect(result?.category, ContentCategory.code);
    });

    test('does not classify plain prose as code', () {
      expect(
        detector.detect(capture('This is a normal sentence.')),
        isNull,
      );
    });
  });
}
