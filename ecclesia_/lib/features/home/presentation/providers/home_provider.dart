import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/models/home_data.dart';

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>(
  (ref) => HomeRemoteDataSource(ref.read(dioProvider)),
);

/// Aggregated home payload for the authenticated faithful.
/// Auto-disposed so it re-fetches each time the home tab is shown.
final homeProvider = FutureProvider.autoDispose<HomeData>(
  (ref) => ref.read(homeRemoteDataSourceProvider).fetchHome(),
);

/// The full agenda (major liturgical feasts + parish events).
final agendaProvider = FutureProvider.autoDispose<List<AgendaEvent>>(
  (ref) => ref.read(homeRemoteDataSourceProvider).fetchAgenda(),
);
