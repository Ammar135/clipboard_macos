import 'package:equatable/equatable.dart';
import '../../domain/entities/clipboard_item.dart';
import '../../domain/entities/clipboard_date_filter.dart';

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
  final ClipboardDateFilter dateFilter;
  final bool isMonitoringEnabled;

  const ClipboardLoaded({
    required this.items,
    this.searchQuery = '',
    this.dateFilter = const ClipboardDateFilterNone(),
    this.isMonitoringEnabled = true,
  });

  ClipboardLoaded copyWith({
    List<ClipboardItem>? items,
    String? searchQuery,
    ClipboardDateFilter? dateFilter,
    bool? isMonitoringEnabled,
  }) {
    return ClipboardLoaded(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      dateFilter: dateFilter ?? this.dateFilter,
      isMonitoringEnabled: isMonitoringEnabled ?? this.isMonitoringEnabled,
    );
  }

  @override
  List<Object?> get props => [items, searchQuery, dateFilter, isMonitoringEnabled];
}

class ClipboardError extends ClipboardState {
  final String message;

  const ClipboardError(this.message);

  @override
  List<Object?> get props => [message];
}
