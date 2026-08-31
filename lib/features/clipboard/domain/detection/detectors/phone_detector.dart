import '../../entities/clipboard_capture.dart';
import '../../entities/content_category.dart';
import '../content_detector.dart';
import '../detection_result.dart';

class PhoneDetector implements ContentDetector {
  static final _phonePattern = RegExp(
    r'^(\+\d{1,3}[\s-]?)?(\d[\s-]?){8,14}\d$',
  );

  @override
  int get priority => 60;

  @override
  ContentCategory get category => ContentCategory.phone;

  @override
  DetectionResult? detect(ClipboardCapture input) {
    if (input.content is! TextClipboardContent) {
      return null;
    }

    final value = (input.content as TextClipboardContent).value.trim();
    if (!_phonePattern.hasMatch(value)) {
      return null;
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 8) {
      return null;
    }

    return DetectionResult(
      category: ContentCategory.phone,
      metadata: {'phone': value},
    );
  }
}
