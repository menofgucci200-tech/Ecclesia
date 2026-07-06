import 'parish_model.dart';

/// A page of parishes, mirroring Laravel's default paginator JSON shape
/// (`data` + `meta.current_page` / `meta.last_page`).
class PaginatedParishes {
  const PaginatedParishes({
    required this.parishes,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<ParishModel> parishes;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;

  factory PaginatedParishes.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as List<dynamic>? ?? [])
        .map((item) => ParishModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final meta = json['meta'] as Map<String, dynamic>? ?? const {};

    return PaginatedParishes(
      parishes: data,
      currentPage: (meta['current_page'] as int?) ?? 1,
      lastPage: (meta['last_page'] as int?) ?? 1,
      total: (meta['total'] as int?) ?? data.length,
    );
  }
}
