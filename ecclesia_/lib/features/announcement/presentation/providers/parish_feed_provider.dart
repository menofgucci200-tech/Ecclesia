import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/announcement_model.dart';
import '../../data/repositories/announcement_repository_impl.dart';

/// The parish feed ("Fil paroissial") for the authenticated faithful.
/// Auto-disposed so it re-fetches each time the home tab is shown.
final parishFeedProvider = FutureProvider.autoDispose<List<AnnouncementModel>>(
  (ref) => ref.read(announcementRepositoryProvider).fetchParishFeed(),
);
