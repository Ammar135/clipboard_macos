import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clipboard_bloc.dart';
import '../bloc/clipboard_event.dart';
import '../bloc/clipboard_state.dart';
import '../../domain/entities/clipboard_date_filter.dart';
import '../widgets/clipboard_item_tile.dart';
import '../widgets/date_filter_button.dart';
import '../widgets/search_field.dart';

class ClipboardHistoryPage extends StatefulWidget {
  const ClipboardHistoryPage({super.key});

  @override
  State<ClipboardHistoryPage> createState() => _ClipboardHistoryPageState();
}

class _ClipboardHistoryPageState extends State<ClipboardHistoryPage> {
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _listFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  
  Timer? _debounce;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initially focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _listFocusNode.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      setState(() => _selectedIndex = 0); // Reset selection on new search
      context.read<ClipboardBloc>().add(ClipboardSearchQueryChanged(query));
    });
  }

  void _onDateFilterChanged(ClipboardDateFilter filter) {
    setState(() => _selectedIndex = 0);
    context.read<ClipboardBloc>().add(ClipboardDateFilterChanged(filter));
  }

  String _emptyStateMessage(ClipboardLoaded state) {
    if (state.searchQuery.isNotEmpty && state.dateFilter.isActive) {
      return 'No results for selected date';
    }
    if (state.searchQuery.isNotEmpty) {
      return 'No results found';
    }
    if (state.dateFilter.isActive) {
      return 'No items for selected date';
    }
    return 'Clipboard is empty';
  }

  /// Maps a ListView row index to an item index, or null for section headers.
  int? _itemIndexForRow({
    required int rowIndex,
    required int pinnedCount,
    required bool showPinnedHeader,
    required bool showRecentHeader,
  }) {
    var i = rowIndex;
    if (showPinnedHeader) {
      if (i == 0) return null;
      i--;
    }
    if (showRecentHeader) {
      if (i == pinnedCount) return null;
      if (i > pinnedCount) i--;
    }
    return i;
  }

  Widget _sectionHeader(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Important for floating panel
      body: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: SearchField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _onSearchChanged,
                  )),
                  BlocBuilder<ClipboardBloc, ClipboardState>(
                    buildWhen: (previous, current) =>
                        current is ClipboardLoaded &&
                        (previous is! ClipboardLoaded ||
                            previous.dateFilter != current.dateFilter),
                    builder: (context, state) {
                      final filter = state is ClipboardLoaded
                          ? state.dateFilter
                          : const ClipboardDateFilterNone();
                      return DateFilterButton(
                        currentFilter: filter,
                        onFilterChanged: _onDateFilterChanged,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close Clipboard',
                    onPressed: () {
                      context.read<ClipboardBloc>().add(ClipboardWindowHidden());
                    },
                  ),
                ],
              ),
              Expanded(
                child: BlocBuilder<ClipboardBloc, ClipboardState>(
                  builder: (context, state) {
                    if (state is ClipboardLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ClipboardError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      );
                    }
                    if (state is ClipboardLoaded) {
                      if (state.items.isEmpty) {
                        return Center(
                          child: Text(
                            _emptyStateMessage(state),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }

                      final items = state.items;
                      final pinnedCount =
                          items.takeWhile((item) => item.isFavorite).length;
                      final showPinnedHeader = pinnedCount > 0;
                      final showRecentHeader =
                          pinnedCount > 0 && pinnedCount < items.length;
                      final rowCount = items.length +
                          (showPinnedHeader ? 1 : 0) +
                          (showRecentHeader ? 1 : 0);
                      final selectedIndex = _selectedIndex.clamp(
                        0,
                        items.length - 1,
                      );

                      return KeyboardListener(
                        focusNode: _listFocusNode,
                        autofocus: true,
                        onKeyEvent: (event) {
                          if (event is KeyDownEvent) {
                            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                              setState(() {
                                if (_selectedIndex < items.length - 1) {
                                  _selectedIndex++;
                                }
                              });
                            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                              setState(() {
                                if (_selectedIndex > 0) {
                                  _selectedIndex--;
                                } else {
                                  _searchFocusNode.requestFocus();
                                }
                              });
                            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                              final item = items[selectedIndex];
                              context.read<ClipboardBloc>().add(ClipboardItemSelected(item.content, item.type));
                            } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                              context.read<ClipboardBloc>().add(ClipboardWindowHidden());
                            }
                          }
                        },
                        child: ListView.builder(
                          itemCount: rowCount,
                          itemBuilder: (context, rowIndex) {
                            if (showPinnedHeader && rowIndex == 0) {
                              return _sectionHeader(
                                context,
                                'Pinned',
                                Icons.push_pin_outlined,
                              );
                            }
                            if (showRecentHeader &&
                                rowIndex == pinnedCount + (showPinnedHeader ? 1 : 0)) {
                              return _sectionHeader(
                                context,
                                'Recent',
                                Icons.history,
                              );
                            }

                            final itemIndex = _itemIndexForRow(
                              rowIndex: rowIndex,
                              pinnedCount: pinnedCount,
                              showPinnedHeader: showPinnedHeader,
                              showRecentHeader: showRecentHeader,
                            )!;
                            final item = items[itemIndex];
                            return ClipboardItemTile(
                              item: item,
                              isSelected: itemIndex == selectedIndex,
                              onSelect: () {
                                setState(() => _selectedIndex = itemIndex);
                                context.read<ClipboardBloc>().add(ClipboardItemSelected(item.content, item.type));
                              },
                              onToggleFavorite: () {
                                context.read<ClipboardBloc>().add(ClipboardFavoriteToggled(item.id));
                              },
                              onDelete: () {
                                context.read<ClipboardBloc>().add(ClipboardItemDeleted(item.id));
                                if (_selectedIndex >= items.length - 1 && _selectedIndex > 0) {
                                  setState(() => _selectedIndex--);
                                }
                              },
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
