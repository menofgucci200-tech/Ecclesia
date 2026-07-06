import '../../data/models/paginated_parishes.dart';
import '../../data/models/parish_model.dart';

/// Contract for parish discovery (list / search / details) and the automatic
/// membership association.
abstract interface class ParishRepository {
  Future<PaginatedParishes> fetchParishes({int page, int perPage});

  Future<PaginatedParishes> searchParishes({
    required String query,
    int page,
    int perPage,
  });

  Future<ParishModel> fetchParish(int id);

  /// Link the authenticated faithful to [parishId]; returns the linked parish.
  Future<ParishModel> associate(int parishId);

  Future<ParishModel?> fetchCurrent();
}
