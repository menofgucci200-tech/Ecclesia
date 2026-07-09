import '../../data/models/announcement_model.dart';

/// Contract for reading the parish feed ("Fil paroissial").
abstract interface class AnnouncementRepository {
  /// The parish feed for the authenticated faithful, pinned items first.
  Future<List<AnnouncementModel>> fetchParishFeed({int perPage});
}
