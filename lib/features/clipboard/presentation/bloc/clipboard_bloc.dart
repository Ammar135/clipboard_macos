import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/clipboard_capture.dart';
import '../../domain/entities/clipboard_date_filter.dart';
import '../../domain/entities/clipboard_item.dart';
import '../../domain/repositories/clipboard_repository.dart';
import '../../domain/usecases/add_clipboard_item.dart';
import '../../../../core/platform/clipboard_platform.dart';
import 'clipboard_event.dart';
import 'clipboard_state.dart';

class ClipboardBloc extends Bloc<ClipboardEvent, ClipboardState> {
  final ClipboardRepository repository;
  final ClipboardPlatform platform;
  final AddClipboardItemUseCase addClipboardItem;
  StreamSubscription? platformEventsSubscription;

  ClipboardBloc({
    required this.repository,
    required this.platform,
    required this.addClipboardItem,
  })  : super(ClipboardInitial()) {
    on<ClipboardLoadHistory>(_onLoadHistory);
    on<ClipboardItemAdded>(_onItemAdded);
    on<ClipboardSearchQueryChanged>(_onSearchQueryChanged);
    on<ClipboardDateFilterChanged>(_onDateFilterChanged);
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

  Future<List<ClipboardItem>> _fetchItems({
    required String searchQuery,
    required ClipboardDateFilter dateFilter,
  }) async {
    final range = dateFilter.toRange();
    if (searchQuery.isEmpty) {
      return repository.getHistory(createdBetween: range);
    }
    return repository.search(searchQuery, createdBetween: range);
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
      final capture = ClipboardCapture.fromPlatformEvent(
        content: event.content,
        platformType: event.type,
        sourceApp: event.sourceApp,
      );

      await addClipboardItem(capture);
      await _refreshLoadedList(emit);
    } catch (_) {
      // Background save error, maybe log it
    }
  }

  Future<void> _refreshLoadedList(Emitter<ClipboardState> emit) async {
    if (state is ClipboardLoaded) {
      final currentState = state as ClipboardLoaded;
      final items = await _fetchItems(
        searchQuery: currentState.searchQuery,
        dateFilter: currentState.dateFilter,
      );
      emit(currentState.copyWith(items: items));
    }
  }

  Future<void> _onSearchQueryChanged(
    ClipboardSearchQueryChanged event,
    Emitter<ClipboardState> emit,
  ) async {
    if (state is ClipboardLoaded) {
      final currentState = state as ClipboardLoaded;
      try {
        final items = await _fetchItems(
          searchQuery: event.query,
          dateFilter: currentState.dateFilter,
        );
        emit(currentState.copyWith(items: items, searchQuery: event.query));
      } catch (e) {
        emit(ClipboardError(e.toString()));
      }
    }
  }

  Future<void> _onDateFilterChanged(
    ClipboardDateFilterChanged event,
    Emitter<ClipboardState> emit,
  ) async {
    if (state is ClipboardLoaded) {
      final currentState = state as ClipboardLoaded;
      try {
        final items = await _fetchItems(
          searchQuery: currentState.searchQuery,
          dateFilter: event.filter,
        );
        emit(currentState.copyWith(items: items, dateFilter: event.filter));
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

        final items = await _fetchItems(
          searchQuery: currentState.searchQuery,
          dateFilter: currentState.dateFilter,
        );
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

        final items = await _fetchItems(
          searchQuery: currentState.searchQuery,
          dateFilter: currentState.dateFilter,
        );
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
    if (event.type == 'image') {
      await platform.copyImageToClipboard(event.content);
    } else {
      await platform.copyToClipboard(event.content);
    }
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
    await platform.showWindow();
  }

  @override
  Future<void> close() {
    platformEventsSubscription?.cancel();
    return super.close();
  }
}
