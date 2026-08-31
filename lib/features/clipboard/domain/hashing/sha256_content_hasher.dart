import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../entities/clipboard_capture.dart';
import 'content_hasher.dart';

class Sha256ContentHasher implements ContentHasher {
  @override
  String hash(ClipboardCapture capture) {
    final content = switch (capture.content) {
      TextClipboardContent(:final value) => value,
      ImageClipboardContent(:final path) => path,
    };

    return sha256.convert(utf8.encode(content)).toString();
  }
}
