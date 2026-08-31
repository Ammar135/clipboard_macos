import 'package:equatable/equatable.dart';

abstract class ClipboardEvent extends Equatable {
  const ClipboardEvent();

  @override
  List<Object?> get props => [];
}

class ClipboardLoadHistory extends ClipboardEvent {}

class ClipboardItemAdded extends ClipboardEvent {
  final String content;
  final String type;
  final String? sourceApp;

  const ClipboardItemAdded({
    required this.content,
    this.type = 'text',
    this.sourceApp,
  });

  @override
  List<Object?> get props => [content, type, sourceApp];
}

class ClipboardSearchQueryChanged extends ClipboardEvent {
  final String query;

  const ClipboardSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ClipboardItemDeleted extends ClipboardEvent {
  final int id;

  const ClipboardItemDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class ClipboardFavoriteToggled extends ClipboardEvent {
  final int id;

  const ClipboardFavoriteToggled(this.id);

  @override
  List<Object?> get props => [id];
}

class ClipboardHistoryCleared extends ClipboardEvent {}

class ClipboardMonitoringToggled extends ClipboardEvent {
  final bool enabled;

  const ClipboardMonitoringToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ClipboardItemSelected extends ClipboardEvent {
  final String content;
  final String type;

  const ClipboardItemSelected(this.content, this.type);

  @override
  List<Object?> get props => [content, type];
}

class ClipboardWindowHidden extends ClipboardEvent {}

class ClipboardShortcutPressed extends ClipboardEvent {}
