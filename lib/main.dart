import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/database/database.dart';
import 'core/platform/clipboard_platform_impl.dart';
import 'features/clipboard/data/repositories/clipboard_repository_impl.dart';
import 'features/clipboard/domain/actions/execute_quick_action.dart';
import 'features/clipboard/domain/actions/quick_action_resolver.dart';
import 'features/clipboard/domain/detection/content_classifier.dart';
import 'features/clipboard/domain/detection/detectors/code_detector.dart';
import 'features/clipboard/domain/detection/detectors/color_detector.dart';
import 'features/clipboard/domain/detection/detectors/email_detector.dart';
import 'features/clipboard/domain/detection/detectors/image_detector.dart';
import 'features/clipboard/domain/detection/detectors/phone_detector.dart';
import 'features/clipboard/domain/detection/detectors/plain_text_detector.dart';
import 'features/clipboard/domain/detection/detectors/url_detector.dart';
import 'features/clipboard/domain/hashing/sha256_content_hasher.dart';
import 'features/clipboard/domain/usecases/add_clipboard_item.dart';
import 'features/clipboard/presentation/bloc/clipboard_bloc.dart';
import 'features/clipboard/presentation/bloc/clipboard_event.dart';
import 'features/clipboard/presentation/pages/clipboard_modern_panel_page.dart';
import 'features/clipboard/presentation/theme/clipboard_ui_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isMacOS) {
    await Window.initialize();
    await Window.makeTitlebarTransparent();
    await Window.setEffect(
      effect: WindowEffect.hudWindow,
      color: ClipboardUiColors.windowTint.withValues(alpha: 0.5),
    );
  }

  final db = AppDatabase();
  final repository = ClipboardRepositoryImpl(db);
  final platform = ClipboardPlatformImpl();
  final classifier = ContentClassifier([
    ImageDetector(),
    UrlDetector(),
    EmailDetector(),
    PhoneDetector(),
    ColorDetector(),
    CodeDetector(),
    PlainTextDetector(),
  ]);
  final addClipboardItem = AddClipboardItemUseCase(
    repository,
    classifier,
    Sha256ContentHasher(),
  );
  final quickActionResolver = QuickActionResolver();
  final executeQuickAction = ExecuteQuickAction(platform);

  runApp(
    RepositoryProvider.value(
      value: quickActionResolver,
      child: RepositoryProvider.value(
        value: executeQuickAction,
        child: BlocProvider(
          create: (context) => ClipboardBloc(
            repository: repository,
            platform: platform,
            addClipboardItem: addClipboardItem,
          )..add(ClipboardLoadHistory()),
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clipboard Manager',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: const ClipboardModernPanelPage(),
    );
  }
}
