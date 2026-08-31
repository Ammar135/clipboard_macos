import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clipboard_project/features/clipboard/presentation/bloc/clipboard_bloc.dart';
import 'package:clipboard_project/features/clipboard/presentation/bloc/clipboard_event.dart';
import 'package:clipboard_project/features/clipboard/presentation/bloc/clipboard_state.dart';
import 'package:clipboard_project/features/clipboard/domain/repositories/clipboard_repository.dart';
import 'package:clipboard_project/core/platform/clipboard_platform.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/clipboard_item.dart';

class MockClipboardRepository extends Mock implements ClipboardRepository {}
class MockClipboardPlatform extends Mock implements ClipboardPlatform {}

// Fallback value for mocked methods that take a ClipboardItem
class FakeClipboardItem extends Fake implements ClipboardItem {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeClipboardItem());
  });

  group('ClipboardBloc', () {
    late MockClipboardRepository mockRepository;
    late MockClipboardPlatform mockPlatform;
    
    setUp(() {
      mockRepository = MockClipboardRepository();
      mockPlatform = MockClipboardPlatform();
      when(() => mockPlatform.events).thenAnswer((_) => const Stream.empty());
    });

    blocTest<ClipboardBloc, ClipboardState>(
      'emits [ClipboardLoading, ClipboardLoaded] when ClipboardLoadHistory is added',
      build: () {
        when(() => mockRepository.getHistory(limit: any(named: 'limit'))).thenAnswer((_) async => []);
        return ClipboardBloc(repository: mockRepository, platform: mockPlatform);
      },
      act: (bloc) => bloc.add(ClipboardLoadHistory()),
      expect: () => [
        isA<ClipboardLoading>(),
        isA<ClipboardLoaded>().having((state) => state.items, 'items', isEmpty),
      ],
    );

    final mockItem = ClipboardItem(
      id: 1,
      content: 'test',
      type: 'text',
      createdAt: DateTime.now(),
      isFavorite: false,
    );

    blocTest<ClipboardBloc, ClipboardState>(
      'emits updated list when ClipboardItemAdded is processed',
      build: () {
        when(() => mockRepository.save(any())).thenAnswer((_) async => {});
        when(() => mockRepository.enforceHistoryLimit(any())).thenAnswer((_) async => {});
        when(() => mockRepository.getHistory(limit: any(named: 'limit'))).thenAnswer((_) async => [mockItem]);
        return ClipboardBloc(repository: mockRepository, platform: mockPlatform);
      },
      seed: () => const ClipboardLoaded(items: []), // Seed to trigger refresh
      act: (bloc) => bloc.add(const ClipboardItemAdded(content: 'test')),
      expect: () => [
        isA<ClipboardLoaded>().having((state) => state.items.length, 'length', 1),
      ],
    );
  });
}
