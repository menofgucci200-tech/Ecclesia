import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcement_remote_data_source.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl(this._remote);

  final AnnouncementRemoteDataSource _remote;

  @override
  Future<List<AnnouncementModel>> fetchParishFeed({int perPage = 15}) =>
      _remote.fetchParishFeed(perPage: perPage);
}

final announcementRemoteDataSourceProvider = Provider<AnnouncementRemoteDataSource>((ref) {
  return AnnouncementRemoteDataSource(ref.read(dioProvider));
});

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(ref.read(announcementRemoteDataSourceProvider));
});
