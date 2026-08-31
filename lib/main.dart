import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/database/database.dart';
import 'core/platform/clipboard_platform_impl.dart';
import 'features/clipboard/data/repositories/clipboard_repository_impl.dart';
import 'features/clipboard/presentation/bloc/clipboard_bloc.dart';
import 'features/clipboard/presentation/bloc/clipboard_event.dart';
import 'features/clipboard/presentation/pages/clipboard_history_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Manual DI Setup
  final db = AppDatabase();
  final repository = ClipboardRepositoryImpl(db);
  final platform = ClipboardPlatformImpl();

  runApp(
    BlocProvider(
      create: (context) => ClipboardBloc(
        repository: repository,
        platform: platform,
      )..add(ClipboardLoadHistory()),
      child: const MyApp(),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const ClipboardHistoryPage(),
    );
  }
}
