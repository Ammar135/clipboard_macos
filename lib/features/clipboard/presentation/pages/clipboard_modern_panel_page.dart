import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/actions/execute_quick_action.dart';
import '../../domain/actions/quick_action_resolver.dart';
import '../../domain/entities/clipboard_date_filter.dart';
import '../../domain/entities/clipboard_item.dart';
import '../bloc/clipboard_bloc.dart';
import '../bloc/clipboard_event.dart';
import '../bloc/clipboard_state.dart';
import '../mappers/clipboard_panel_ui_mapper.dart';
import '../models/clipboard_card_ui_model.dart';
import '../widgets/modern/clipboard_modern_panel.dart';
import '../widgets/modern/compact_date_filter_button.dart';

class ClipboardModernPanelPage extends StatefulWidget {
  const ClipboardModernPanelPage({super.key});

  @override
  State<ClipboardModernPanelPage> createState() => _ClipboardModernPanelPageState();
}

class _ClipboardModernPanelPageState extends State<ClipboardModernPanelPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _listFocusNode = FocusNode();
  Timer? _debounce;
  int? _selectedItemId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _listFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      setState(() => _selectedItemId = null);
      context.read<ClipboardBloc>().add(ClipboardSearchQueryChanged(query));
    });
  }

  String _emptyMessage(ClipboardLoaded state) {
    if (state.searchQuery.isNotEmpty && state.dateFilter.isActive) {
      return 'No results for selected filters';
    }
    if (state.searchQuery.isNotEmpty) {
      return 'No results found';
    }
    if (state.dateFilter.isActive || state.categoryFilter != null) {
      return 'No items for selected filters';
    }
    return 'Clipboard is empty';
  }

  ClipboardItem _findItem(BuildContext context, int itemId) {
    final state = context.read<ClipboardBloc>().state as ClipboardLoaded;
    return state.items.firstWhere((item) => item.id == itemId);
  }

  void _selectItem(ClipboardCardUiModel card) {
    setState(() => _selectedItemId = card.itemId);
    final item = _findItem(context, card.itemId);
    context.read<ClipboardBloc>().add(
          ClipboardItemSelected(item.content, item.type),
        );
  }

  void _onQuickAction(ClipboardCardUiModel card, String actionLabel) {
    final item = _findItem(context, card.itemId);
    final resolver = context.read<QuickActionResolver>();
    final executor = context.read<ExecuteQuickAction>();
    final actions = resolver
        .resolve(item)
        .where((entry) => entry.label == actionLabel);
    if (actions.isNotEmpty) {
      executor(actions.first);
    }
  }

  void _clearHistory() {
    setState(() => _selectedItemId = null);
    context.read<ClipboardBloc>().add(ClipboardHistoryCleared());
  }

  Future<void> _showItemMenu(ClipboardCardUiModel card) async {
    final item = _findItem(context, card.itemId);
    final action = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(300, 300, 100, 100),
      items: [
        PopupMenuItem(
          value: item.isFavorite ? 'unpin' : 'pin',
          child: Text(item.isFavorite ? 'Unpin' : 'Pin'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
    );

    if (!mounted || action == null) return;

    final bloc = context.read<ClipboardBloc>();
    if (action == 'delete') {
      bloc.add(ClipboardItemDeleted(item.id));
    } else {
      bloc.add(ClipboardFavoriteToggled(item.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<ClipboardBloc, ClipboardState>(
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

          if (state is! ClipboardLoaded) {
            return const SizedBox.shrink();
          }

          final viewData = ClipboardPanelUiMapper.map(
            items: state.items,
            categoryFilter: state.categoryFilter,
            selectedItemId: _selectedItemId,
            locale: Localizations.localeOf(context),
          );

          return KeyboardListener(
            focusNode: _listFocusNode,
            autofocus: true,
            onKeyEvent: (event) {
              if (event is! KeyDownEvent) return;

              final flatCards = <ClipboardCardUiModel>[
                ...viewData.pinnedSection.listItems,
                ...viewData.pinnedSection.gridItems,
                for (final section in viewData.sections) ...[
                  ...section.listItems,
                  ...section.gridItems,
                ],
              ];

              if (flatCards.isEmpty) return;

              final currentIndex = flatCards
                  .indexWhere((card) => card.itemId == _selectedItemId);

              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                setState(() {
                  final nextIndex = currentIndex < 0
                      ? 0
                      : (currentIndex + 1).clamp(0, flatCards.length - 1);
                  _selectedItemId = flatCards[nextIndex].itemId;
                });
              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                if (currentIndex <= 0) {
                  _searchFocusNode.requestFocus();
                } else {
                  setState(() {
                    _selectedItemId = flatCards[currentIndex - 1].itemId;
                  });
                }
              } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                final selectedId = _selectedItemId ?? flatCards.first.itemId;
                final card = flatCards
                    .firstWhere((entry) => entry.itemId == selectedId);
                _selectItem(card);
              } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                context.read<ClipboardBloc>().add(ClipboardWindowHidden());
              }
            },
            child: Align(
              alignment: Alignment.center,
              child: ClipboardModernPanel(
                categoryChips: viewData.categoryChips,
                pinnedSection: viewData.pinnedSection,
                sections: viewData.sections,
                totalItemCount: viewData.totalItemCount,
                isFilterActive: state.dateFilter.isActive,
                emptyMessage: _emptyMessage(state),
                searchController: _searchController,
                searchFocusNode: _searchFocusNode,
                onSearchChanged: _onSearchChanged,
                dateFilterButton: CompactDateFilterButton(
                  currentFilter: state.dateFilter,
                  onFilterChanged: (ClipboardDateFilter filter) {
                    setState(() => _selectedItemId = null);
                    context
                        .read<ClipboardBloc>()
                        .add(ClipboardDateFilterChanged(filter));
                  },
                ),
                onCloseTap: () =>
                    context.read<ClipboardBloc>().add(ClipboardWindowHidden()),
                onCategoryChipTap: (chip) {
                  setState(() => _selectedItemId = null);
                  final currentFilter =
                      (context.read<ClipboardBloc>().state as ClipboardLoaded)
                          .categoryFilter;
                  final nextCategory =
                      chip.category == currentFilter ? null : chip.category;
                  context.read<ClipboardBloc>().add(
                        ClipboardCategoryFilterChanged(nextCategory),
                      );
                },
                onItemTap: _selectItem,
                onFavoriteTap: (card) => context
                    .read<ClipboardBloc>()
                    .add(ClipboardFavoriteToggled(card.itemId)),
                onMoreTap: _showItemMenu,
                onQuickActionTap: _onQuickAction,
                onClearHistoryTap: _clearHistory,
              ),
            ),
          );
        },
      ),
    );
  }
}
