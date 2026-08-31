import 'package:clipboard_project/features/clipboard/domain/entities/clipboard_capture.dart';
import 'package:clipboard_project/features/clipboard/domain/hashing/sha256_content_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final hasher = Sha256ContentHasher();

  test('same input produces same hash', () {
    final capture = ClipboardCapture(
      content: const TextClipboardContent('hello'),
      capturedAt: DateTime(2026),
    );

    expect(hasher.hash(capture), hasher.hash(capture));
  });

  test('different input produces different hash', () {
    final first = ClipboardCapture(
      content: const TextClipboardContent('hello'),
      capturedAt: DateTime(2026),
    );
    final second = ClipboardCapture(
      content: const TextClipboardContent('world'),
      capturedAt: DateTime(2026),
    );

    expect(hasher.hash(first), isNot(hasher.hash(second)));
  });
}
