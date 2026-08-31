import '../entities/clipboard_capture.dart';

abstract interface class ContentHasher {
  String hash(ClipboardCapture capture);
}
