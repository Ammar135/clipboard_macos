import 'package:clipboard_project/features/clipboard/domain/clipboard_history_policy.dart';
import 'package:clipboard_project/features/clipboard/domain/detection/content_classifier.dart';
import 'package:clipboard_project/features/clipboard/domain/detection/detectors/plain_text_detector.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/clipboard_capture.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/clipboard_item.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/content_category.dart';
import 'package:clipboard_project/features/clipboard/domain/hashing/content_hasher.dart';
import 'package:clipboard_project/features/clipboard/domain/repositories/clipboard_repository.dart';
import 'package:clipboard_project/features/clipboard/domain/usecases/add_clipboard_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClipboardRepository extends Mock implements ClipboardRepository {}

class FakeContentHasher implements ContentHasher {
  @override
  String hash(ClipboardCapture capture) {
    return switch (capture.content) {
      TextClipboardContent(:final value) => 'hash:$value',
      ImageClipboardContent(:final path) => 'hash:$path',
    };
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      ClipboardItem(
        id: 0,
        content: '',
        category: ContentCategory.text,
        createdAt: DateTime(2026),
        isFavorite: false,
      ),
    );
  });

  late MockClipboardRepository repository;
  late AddClipboardItemUseCase useCase;

  setUp(() {
    repository = MockClipboardRepository();
    useCase = AddClipboardItemUseCase(
      repository,
      ContentClassifier([PlainTextDetector()]),
      FakeContentHasher(),
      const ClipboardHistoryPolicy(maxItems: 1000),
    );

    when(() => repository.save(any())).thenAnswer((_) async {});
    when(() => repository.enforceHistoryLimit(any())).thenAnswer((_) async {});
    when(() => repository.touchLastUsed(any())).thenAnswer((_) async {});
    when(() => repository.findByContentHash(any())).thenAnswer((_) async => null);
  });

  ClipboardCapture capture(String value) {
    return ClipboardCapture(
      content: TextClipboardContent(value),
      capturedAt: DateTime(2026),
      sourceApp: 'Safari',
    );
  }

  test('saves new content', () async {
    await useCase(capture('hello'));

    verify(() => repository.save(any(
          that: predicate<ClipboardItem>(
            (item) =>
                item.content == 'hello' &&
                item.category == ContentCategory.text &&
                item.contentHash == 'hash:hello',
          ),
        ))).called(1);
    verify(() => repository.enforceHistoryLimit(1000)).called(1);
  });

  test('touches existing content instead of saving duplicate', () async {
    final existing = ClipboardItem(
      id: 7,
      content: 'hello',
      category: ContentCategory.text,
      contentHash: 'hash:hello',
      createdAt: DateTime(2025),
      isFavorite: true,
    );

    when(() => repository.findByContentHash('hash:hello'))
        .thenAnswer((_) async => existing);

    await useCase(capture('hello'));

    verify(() => repository.touchLastUsed(7)).called(1);
    verifyNever(() => repository.save(any()));
  });
}
