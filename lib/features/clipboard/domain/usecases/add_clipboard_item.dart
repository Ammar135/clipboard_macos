import '../entities/clipboard_capture.dart';
import '../entities/clipboard_item.dart';
import '../repositories/clipboard_repository.dart';
import '../clipboard_history_policy.dart';
import '../detection/content_classifier.dart';
import '../hashing/content_hasher.dart';

class AddClipboardItemUseCase {
  final ClipboardRepository _repository;
  final ContentClassifier _classifier;
  final ContentHasher _hasher;
  final ClipboardHistoryPolicy _historyPolicy;

  const AddClipboardItemUseCase(
    this._repository,
    this._classifier,
    this._hasher, [
    this._historyPolicy = const ClipboardHistoryPolicy(),
  ]);

  Future<void> call(ClipboardCapture capture) async {
    final detection = _classifier.classify(capture);
    final content = _extractContent(capture);
    final hash = _hasher.hash(capture);

    final existing = await _repository.findByContentHash(hash);
    if (existing != null) {
      await _repository.touchLastUsed(existing.id);
      return;
    }

    final item = ClipboardItem(
      id: 0,
      content: content,
      category: detection.category,
      contentHash: hash,
      createdAt: capture.capturedAt,
      sourceApp: capture.sourceApp,
      isFavorite: false,
    );

    try {
      await _repository.save(item);
    } catch (_) {
      final duplicate = await _repository.findByContentHash(hash);
      if (duplicate != null) {
        await _repository.touchLastUsed(duplicate.id);
        return;
      }
      rethrow;
    }

    await _repository.enforceHistoryLimit(_historyPolicy.maxItems);
  }

  String _extractContent(ClipboardCapture capture) {
    return switch (capture.content) {
      TextClipboardContent(:final value) => value,
      ImageClipboardContent(:final path) => path,
    };
  }
}
