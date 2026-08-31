import 'package:clipboard_project/features/clipboard/domain/entities/clipboard_capture.dart';
import 'package:clipboard_project/core/platform/clipboard_platform.dart';
import 'package:clipboard_project/features/clipboard/domain/actions/execute_quick_action.dart';
import 'package:clipboard_project/features/clipboard/domain/actions/quick_action_resolver.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/clipboard_item.dart';
import 'package:clipboard_project/features/clipboard/domain/entities/content_category.dart';
import 'package:clipboard_project/features/clipboard/domain/repositories/clipboard_repository.dart';
import 'package:clipboard_project/features/clipboard/domain/usecases/add_clipboard_item.dart';
import 'package:clipboard_project/features/clipboard/presentation/bloc/clipboard_bloc.dart';
import 'package:clipboard_project/features/clipboard/presentation/bloc/clipboard_event.dart';
import 'package:clipboard_project/features/clipboard/presentation/pages/clipboard_modern_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
  });

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
  });

  Widget buildTestApp(ClipboardBloc bloc) {
    when(() => mockPlatform.getLaunchAtLogin()).thenAnswer((_) async => false);
    when(() => mockPlatform.setLaunchAtLogin(any())).thenAnswer((_) async {});
    when(() => mockPlatform.isAccessibilityGranted()).thenAnswer((_) async => true);
    when(() => mockPlatform.requestAccessibility()).thenAnswer((_) async => true);
    when(() => mockPlatform.isShortcutRegistered()).thenAnswer((_) async => true);
    when(() => mockPlatform.reregisterShortcut()).thenAnswer((_) async {});
    when(() => mockPlatform.getAppBundlePath()).thenAnswer((_) async => '/Applications/clipboard_project.app');
    when(() => mockPlatform.getExecutablePath()).thenAnswer((_) async => '/Applications/clipboard_project.app/Contents/MacOS/clipboard_project');
    when(() => mockPlatform.showWindow()).thenAnswer((_) async {});
    when(() => mockPlatform.hideWindow()).thenAnswer((_) async {});

    return RepositoryProvider<ClipboardPlatform>.value(
      value: mockPlatform,
      child: RepositoryProvider<QuickActionResolver>(
        create: (_) => QuickActionResolver(),
        child: RepositoryProvider<ExecuteQuickAction>(
          create: (_) => ExecuteQuickAction(mockPlatform),
          child: BlocProvider<ClipboardBloc>.value(
            value: bloc,
            child: const MaterialApp(home: ClipboardModernPanelPage()),
          ),
        ),
      ),
    );
  }

  testWidgets('modern panel renders items from bloc state', (tester) async {
    final now = DateTime.now();
    final items = [
      ClipboardItem(
        id: 1,
        content: 'https://github.com/user/repo',
        category: ContentCategory.url,
        createdAt: now,
        sourceApp: 'Safari',
        isFavorite: true,
      ),
      ClipboardItem(
        id: 2,
        content: 'function hello() { return 1; }',
        category: ContentCategory.code,
        createdAt: now,
        sourceApp: 'VS Code',
        isFavorite: false,
      ),
      ClipboardItem(
        id: 3,
        content: '#FF5733',
        category: ContentCategory.color,
        createdAt: now,
        sourceApp: 'Figma',
        isFavorite: false,
      ),
    ];

    when(
      () => mockRepository.getHistory(
        limit: any(named: 'limit'),
        createdBetween: any(named: 'createdBetween'),
      ),
    ).thenAnswer((_) async => items);

    final bloc = ClipboardBloc(
      repository: mockRepository,
      platform: mockPlatform,
      addClipboardItem: mockAddClipboardItem,
    )..add(ClipboardLoadHistory());

    await tester.pumpWidget(buildTestApp(bloc));
    await tester.pump();
    await tester.pump();

    expect(find.text('PINNED'), findsOneWidget);
    expect(find.textContaining('TODAY'), findsOneWidget);
    expect(find.text('https://github.com/user/repo'), findsOneWidget);
    expect(
      find.textContaining('function hello() { return 1; }'),
      findsOneWidget,
    );
    expect(find.text('#FF5733'), findsOneWidget);
    expect(find.textContaining('3 items'), findsOneWidget);
  });

  testWidgets('modern panel shows empty state when no items', (tester) async {
    final bloc = ClipboardBloc(
      repository: mockRepository,
      platform: mockPlatform,
      addClipboardItem: mockAddClipboardItem,
    )..add(ClipboardLoadHistory());

    await tester.pumpWidget(buildTestApp(bloc));
    await tester.pump();
    await tester.pump();

    expect(find.text('Clipboard is empty'), findsOneWidget);
  });
}
