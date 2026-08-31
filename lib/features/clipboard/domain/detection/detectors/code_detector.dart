import 'dart:convert';

import '../../entities/clipboard_capture.dart';
import '../../entities/content_category.dart';
import '../content_detector.dart';
import '../detection_result.dart';

class CodeDetector implements ContentDetector {
  @override
  int get priority => 40;

  @override
  ContentCategory get category => ContentCategory.code;

  @override
  DetectionResult? detect(ClipboardCapture input) {
    if (input.content is! TextClipboardContent) {
      return null;
    }

    final value = (input.content as TextClipboardContent).value.trim();
    if (value.isEmpty) {
      return null;
    }

    if (_isJson(value)) {
      return const DetectionResult(
        category: ContentCategory.code,
        metadata: {'language': 'json'},
      );
    }

    if (_looksLikeCode(value)) {
      return const DetectionResult(category: ContentCategory.code);
    }

    return null;
  }

  bool _isJson(String value) {
    try {
      final decoded = jsonDecode(value);
      return decoded is Map || decoded is List;
    } catch (_) {
      return false;
    }
  }

  bool _looksLikeCode(String value) {
    if (!value.contains('\n')) {
      return false;
    }

    final lines = value.split('\n');
    if (lines.length < 2) {
      return false;
    }

    final codeSignals = [
      RegExp(r'\b(function|class|import|export|const|let|var|def|void|return)\b'),
      RegExp(r'[{}();]'),
      RegExp(r'^\s*(public|private|protected)\s'),
    ];

    var signalCount = 0;
    for (final pattern in codeSignals) {
      if (pattern.hasMatch(value)) {
        signalCount++;
      }
    }

    return signalCount >= 2;
  }
}
