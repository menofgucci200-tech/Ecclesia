import 'package:equatable/equatable.dart';

import '../../data/models/parish_model.dart';

/// The accumulated, paginated result set of the parish list / search.
class ParishListState extends Equatable {
  const ParishListState({
    this.parishes = const [],
    this.query = '',
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.isLoadingMore = false,
  });

  final List<ParishModel> parishes;
  final String query;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoadingMore;

  bool get hasMore => currentPage < lastPage;
  bool get isEmpty => parishes.isEmpty;

  ParishListState copyWith({
    List<ParishModel>? parishes,
    String? query,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoadingMore,
  }) {
    return ParishListState(
      parishes: parishes ?? this.parishes,
      query: query ?? this.query,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [parishes, query, currentPage, lastPage, total, isLoadingMore];
}
