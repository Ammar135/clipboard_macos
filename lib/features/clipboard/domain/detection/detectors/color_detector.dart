import '../../entities/clipboard_capture.dart';
import '../../entities/content_category.dart';
import '../content_detector.dart';
import '../detection_result.dart';

class ColorDetector implements ContentDetector {
  static final _hexPattern = RegExp(r'^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$');
  static final _rgbPattern = RegExp(
    r'^rgba?\(\s*\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3}\s*(,\s*(0|1|0?\.\d+))?\s*\)$',
  );

  @override
  int get priority => 50;

  @override
  ContentCategory get category => ContentCategory.color;

  @override
  DetectionResult? detect(ClipboardCapture input) {
    if (input.content is! TextClipboardContent) {
      return null;
    }

    final value = (input.content as TextClipboardContent).value.trim();
    if (_hexPattern.hasMatch(value)) {
      return DetectionResult(
        category: ContentCategory.color,
        metadata: {'hex': _normalizeHex(value)},
      );
    }

    if (_rgbPattern.hasMatch(value)) {
      return DetectionResult(
        category: ContentCategory.color,
        metadata: {'value': value},
      );
    }

    return null;
  }

  String _normalizeHex(String value) {
    if (value.length == 4) {
      final r = value[1];
      final g = value[2];
      final b = value[3];
      return '#$r$r$g$g$b$b'.toUpperCase();
    }
    return value.toUpperCase();
  }
}
