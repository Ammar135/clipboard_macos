import 'package:equatable/equatable.dart';
import '../../domain/entities/clipboard_item.dart';

abstract class ClipboardState extends Equatable {
  const ClipboardState();

  @override
  List<Object?> get props => [];
}

class ClipboardInitial extends ClipboardState {}

class ClipboardLoading extends ClipboardState {}

class ClipboardLoaded extends ClipboardState {
  final List<ClipboardItem> items;
  final String searchQuery;
  final bool isMonitoringEnabled;

  const ClipboardLoaded({
    required this.items,
    this.searchQuery = '',
    this.isMonitoringEnabled = true,
  });

  ClipboardLoaded copyWith({
    List<ClipboardItem>? items,
    String? searchQuery,
    bool? isMonitoringEnabled,
  }) {
    return ClipboardLoaded(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      isMonitoringEnabled: isMonitoringEnabled ?? this.isMonitoringEnabled,
    );
  }

  @override
  List<Object?> get props => [items, searchQuery, isMonitoringEnabled];
}

class ClipboardError extends ClipboardState {
  final String message;

  const ClipboardError(this.message);

  @override
  List<Object?> get props => [message];
}
