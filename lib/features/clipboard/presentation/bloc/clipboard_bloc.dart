import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/clipboard_item.dart';
import '../../domain/repositories/clipboard_repository.dart';
import '../../../../core/platform/clipboard_platform.dart';
import 'clipboard_event.dart';
import 'clipboard_state.dart';

class ClipboardBloc extends Bloc<ClipboardEvent, ClipboardState> {
  final ClipboardRepository repository;
  final ClipboardPlatform platform;
  StreamSubscription? platformEventsSubscription;

  ClipboardBloc({
    required this.repository,
    required this.platform,
  })  : super(ClipboardInitial()) {
    on<ClipboardLoadHistory>(_onLoadHistory);
    on<ClipboardItemAdded>(_onItemAdded);
    on<ClipboardSearchQueryChanged>(_onSearchQueryChanged);
    on<ClipboardItemDeleted>(_onItemDeleted);
    on<ClipboardFavoriteToggled>(_onFavoriteToggled);
    on<ClipboardHistoryCleared>(_onHistoryCleared);
    on<ClipboardMonitoringToggled>(_onMonitoringToggled);
    on<ClipboardItemSelected>(_onItemSelected);
    on<ClipboardWindowHidden>(_onWindowHidden);
    on<ClipboardShortcutPressed>(_onShortcutPressed);

    _listenToPlatformEvents();
  }

  void _listenToPlatformEvents() {
    platformEventsSubscription = platform.events.listen((event) {
      final eventName = event['event'] as String?;
      if (eventName == 'clipboard_changed') {
        add(ClipboardItemAdded(
          content: event['content'] as String,
          type: event['type'] as String? ?? 'text',
          sourceApp: event['sourceApp'] as String?,
        ));
      } else if (eventName == 'shortcut_pressed') {
        add(ClipboardShortcutPressed());
      } else if (eventName == 'clear_history') {
        add(ClipboardHistoryCleared());
      }
    });
  }

  Future<void> _onLoadHistory(
    ClipboardLoadHistory event,
    Emitter<ClipboardState> emit,
  ) async {
    emit(ClipboardLoading());
    try {
      final items = await repository.getHistory();
      emit(ClipboardLoaded(items: items));
    } catch (e) {
      emit(ClipboardError(e.toString()));
    }
  }

  Future<void> _onItemAdded(
    ClipboardItemAdded event,
    Emitter<ClipboardState> emit,
  ) async {
    try {
      final newItem = ClipboardItem(
        id: 0, // Auto-incremented by DB
        content: event.content,
        type: event.type,
        createdAt: DateTime.now(),
        sourceApp: event.sourceApp,
        isFavorite: false,
      );

      await repository.save(newItem);
      await repository.enforceHistoryLimit(1000);

      // If we are loaded and not searching, refresh the list
      if (state is ClipboardLoaded) {
        final currentState = state as ClipboardLoaded;
        if (currentState.searchQuery.isEmpty) {
          final items = await repository.getHistory();
          emit(currentState.copyWith(items: items));
        }
      }
    } catch (e) {
      // Background save error, maybe log it
    }
  }

  Future<void> _onSearchQueryChanged(
    ClipboardSearchQueryChanged event,
    Emitter<ClipboardState> emit,
  ) async {
    if (state is ClipboardLoaded) {
      final currentState = state as ClipboardLoaded;
      try {
        List<ClipboardItem> items;
        if (event.query.isEmpty) {
          items = await repository.getHistory();
        } else {
          items = await repository.search(event.query);
        }
        emit(currentState.copyWith(items: items, searchQuery: event.query));
      } catch (e) {
        emit(ClipboardError(e.toString()));
      }
    }
  }

  Future<void> _onItemDeleted(
    ClipboardItemDeleted event,
    Emitter<ClipboardState> emit,
  ) async {
    if (state is ClipboardLoaded) {
      final currentState = state as ClipboardLoaded;
      try {
        await repository.delete(event.id);
        
        // Refresh current view
        List<ClipboardItem> items;
        if (currentState.searchQuery.isEmpty) {
          items = await repository.getHistory();
        } else {
          items = await repository.search(currentState.searchQuery);
        }
        emit(currentState.copyWith(items: items));
      } catch (e) {
        // Log error
      }
    }
  }

  Future<void> _onFavoriteToggled(
    ClipboardFavoriteToggled event,
    Emitter<ClipboardState> emit,
  ) async {
    if (state is ClipboardLoaded) {
      final currentState = state as ClipboardLoaded;
      try {
        await repository.toggleFavorite(event.id);
        
        // Refresh current view
        List<ClipboardItem> items;
        if (currentState.searchQuery.isEmpty) {
          items = await repository.getHistory();
        } else {
          items = await repository.search(currentState.searchQuery);
        }
        emit(currentState.copyWith(items: items));
      } catch (e) {
        // Log error
      }
    }
  }

  Future<void> _onHistoryCleared(
    ClipboardHistoryCleared event,
    Emitter<ClipboardState> emit,
  ) async {
    if (state is ClipboardLoaded) {
      final currentState = state as ClipboardLoaded;
      try {
        await repository.clear();
        emit(currentState.copyWith(items: []));
      } catch (e) {
        emit(ClipboardError(e.toString()));
      }
    }
  }

  Future<void> _onMonitoringToggled(
    ClipboardMonitoringToggled event,
    Emitter<ClipboardState> emit,
  ) async {
    if (state is ClipboardLoaded) {
      final currentState = state as ClipboardLoaded;
      await platform.setMonitoringEnabled(event.enabled);
      emit(currentState.copyWith(isMonitoringEnabled: event.enabled));
    }
  }

  Future<void> _onItemSelected(
    ClipboardItemSelected event,
    Emitter<ClipboardState> emit,
  ) async {
    // Copy to clipboard based on type
    if (event.type == 'image') {
      await platform.copyImageToClipboard(event.content);
    } else {
      await platform.copyToClipboard(event.content);
    }
    // Hide window
    await platform.hideWindow();
  }

  Future<void> _onWindowHidden(
    ClipboardWindowHidden event,
    Emitter<ClipboardState> emit,
  ) async {
    await platform.hideWindow();
  }

  Future<void> _onShortcutPressed(
    ClipboardShortcutPressed event,
    Emitter<ClipboardState> emit,
  ) async {
    // Show window on global shortcut
    await platform.showWindow();
  }

  @override
  Future<void> close() {
    platformEventsSubscription?.cancel();
    return super.close();
  }
}
