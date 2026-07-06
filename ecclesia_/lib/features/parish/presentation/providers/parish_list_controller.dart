import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/paginated_parishes.dart';
import '../../data/repositories/parish_repository_impl.dart';
import 'parish_list_state.dart';

/// Drives the searchable, infinitely-paginated list of joinable parishes.
/// Search is debounced by 300ms.
class ParishListController extends AsyncNotifier<ParishListState> {
  Timer? _debounce;

  static const Duration _debounceDelay = Duration(milliseconds: 300);

  @override
  Future<ParishListState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    return _fetch(page: 1, query: '');
  }

  /// Debounced search entry point, wired to the search field.
  void search(String term) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () => _runSearch(term.trim()));
  }

  Future<void> _runSearch(String query) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(page: 1, query: query));
  }

  /// Pull-to-refresh: reload the first page for the current query.
  Future<void> refresh() async {
    final query = state.value?.query ?? '';
    state = await AsyncValue.guard(() => _fetch(page: 1, query: query));
  }

  /// Load the next page and append it (infinite scroll).
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final next = await _fetch(page: current.currentPage + 1, query: current.query);
      state = AsyncData(
        next.copyWith(parishes: [...current.parishes, ...next.parishes]),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<ParishListState> _fetch({required int page, required String query}) async {
    final repository = ref.read(parishRepositoryProvider);

    final PaginatedParishes result = query.isEmpty
        ? await repository.fetchParishes(page: page)
        : await repository.searchParishes(query: query, page: page);

    return ParishListState(
      parishes: result.parishes,
      query: query,
      currentPage: result.currentPage,
      lastPage: result.lastPage,
      total: result.total,
    );
  }
}

final parishListControllerProvider =
    AsyncNotifierProvider<ParishListController, ParishListState>(
  ParishListController.new,
);
