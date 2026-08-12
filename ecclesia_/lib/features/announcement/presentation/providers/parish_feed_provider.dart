import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/announcement_comment_model.dart';
import '../../data/models/announcement_model.dart';
import '../../data/repositories/announcement_repository_impl.dart';

/// The parish feed ("Fil paroissial") for the authenticated faithful.
/// Auto-disposed so it re-fetches each time the home tab is shown.
final parishFeedProvider = FutureProvider.autoDispose<List<AnnouncementModel>>(
  (ref) => ref.read(announcementRepositoryProvider).fetchParishFeed(),
);

/// The full feed ("Voir tout"), fetched with a higher page size.
final parishFeedFullProvider = FutureProvider.autoDispose<List<AnnouncementModel>>(
  (ref) => ref.read(announcementRepositoryProvider).fetchParishFeed(perPage: 50),
);

/// The faithful's saved ("Enregistrées") announcements.
final savedAnnouncementsProvider = FutureProvider.autoDispose<List<AnnouncementModel>>(
  (ref) => ref.read(announcementRemoteDataSourceProvider).fetchSaved(),
);

/// Comments on a given announcement.
final announcementCommentsProvider = FutureProvider.autoDispose.family<List<AnnouncementCommentModel>, int>(
  (ref, announcementId) => ref.read(announcementRemoteDataSourceProvider).fetchComments(announcementId),
);
