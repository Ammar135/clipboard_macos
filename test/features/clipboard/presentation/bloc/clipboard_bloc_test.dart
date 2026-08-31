import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clipboard_project/features/clipboard/presentation/bloc/clipboard_bloc.dart';
import 'package:clipboard_project/features/clipboard/presentation/bloc/clipboard_event.dart';
import 'package:clipboard_project/features/clipboard/presentation/bloc/clipboard_state.dart';
import 'package:clipboard_project/features/clipboard/domain/repositories/clipboard_repository.dart';
import 'package:clipboard_project/core/platform/clipboard_platform.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/clipboard_item.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/clipboard_capture.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/clipboard_date_filter.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/content_category.dart';
import 'package:clipboard_project/features/clipboard/domain/usecases/add_clipboard_item.dart';

class MockClipboardRepository extends Mock implements ClipboardRepository {}
class MockClipboardPlatform extends Mock implements ClipboardPlatform {}
class MockAddClipboardItemUseCase extends Mock implements AddClipboardItemUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      ClipboardCapture(
        content: const TextClipboardContent(''),
        capturedAt: DateTime(2026),
      ),
    );
    registerFallbackValue(
      DateTimeRange(
        start: DateTime(2026, 8, 31),
        end: DateTime(2026, 9, 1),
      ),
    );
    registerFallbackValue(const ClipboardDateFilterNone());
  });

  group('ClipboardBloc', () {
    late MockClipboardRepository mockRepository;
    late MockClipboardPlatform mockPlatform;
    late MockAddClipboardItemUseCase mockAddClipboardItem;
    
    setUp(() {
      mockRepository = MockClipboardRepository();
      mockPlatform = MockClipboardPlatform();
      mockAddClipboardItem = MockAddClipboardItemUseCase();
      when(() => mockPlatform.events).thenAnswer((_) => const Stream.empty());
      when(() => mockAddClipboardItem.call(any())).thenAnswer((_) async {});
      when(
        () => mockRepository.getHistory(
          limit: any(named: 'limit'),
          createdBetween: any(named: 'createdBetween'),
        ),
      ).thenAnswer((_) async => []);
      when(
        () => mockRepository.search(
          any(),
          limit: any(named: 'limit'),
          createdBetween: any(named: 'createdBetween'),
        ),
      ).thenAnswer((_) async => []);
    });

    ClipboardBloc buildBloc() {
      return ClipboardBloc(
        repository: mockRepository,
        platform: mockPlatform,
        addClipboardItem: mockAddClipboardItem,
      );
    }

    blocTest<ClipboardBloc, ClipboardState>(
      'emits [ClipboardLoading, ClipboardLoaded] when ClipboardLoadHistory is added',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(ClipboardLoadHistory()),
      expect: () => [
        isA<ClipboardLoading>(),
        isA<ClipboardLoaded>().having((state) => state.items, 'items', isEmpty),
      ],
    );

    final mockItem = ClipboardItem(
      id: 1,
      content: 'test',
      category: ContentCategory.text,
      createdAt: DateTime.now(),
      isFavorite: false,
    );

    blocTest<ClipboardBloc, ClipboardState>(
      'delegates ClipboardItemAdded to use case and refreshes list',
      build: () {
        when(
          () => mockRepository.getHistory(
            limit: any(named: 'limit'),
            createdBetween: any(named: 'createdBetween'),
          ),
        ).thenAnswer((_) async => [mockItem]);
        return buildBloc();
      },
      seed: () => const ClipboardLoaded(items: []),
      act: (bloc) => bloc.add(const ClipboardItemAdded(content: 'test')),
      expect: () => [
        isA<ClipboardLoaded>().having((state) => state.items.length, 'length', 1),
      ],
      verify: (_) {
        verify(() => mockAddClipboardItem.call(any())).called(1);
      },
    );

    blocTest<ClipboardBloc, ClipboardState>(
      'applies date filter and search together',
      build: () {
        when(
          () => mockRepository.search(
            'hello',
            limit: any(named: 'limit'),
            createdBetween: any(named: 'createdBetween'),
          ),
        ).thenAnswer((_) async => [mockItem]);
        return buildBloc();
      },
      seed: () => const ClipboardLoaded(items: [], searchQuery: 'hello'),
      act: (bloc) => bloc.add(
        const ClipboardDateFilterChanged(
          ClipboardDateFilterPreset(ClipboardDateFilterPresetType.today),
        ),
      ),
      expect: () => [
        isA<ClipboardLoaded>()
            .having((state) => state.items.length, 'length', 1)
            .having(
              (state) => state.dateFilter,
              'dateFilter',
              const ClipboardDateFilterPreset(ClipboardDateFilterPresetType.today),
            ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.search(
            'hello',
            limit: any(named: 'limit'),
            createdBetween: any(named: 'createdBetween'),
          ),
        ).called(1);
      },
    );
  });
}
