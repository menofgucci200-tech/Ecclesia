import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/movement_remote_data_source.dart';
import '../../data/models/movement.dart';

final movementDataSourceProvider = Provider<MovementRemoteDataSource>(
  (ref) => MovementRemoteDataSource(ref.read(dioProvider)),
);

/// All active movements of the faithful's parish.
final parishMovementsProvider = FutureProvider.autoDispose<List<Movement>>(
  (ref) => ref.read(movementDataSourceProvider).fetchParishMovements(),
);

/// The movements the faithful belongs to (for "Mes activités").
final myMovementsProvider = FutureProvider.autoDispose<List<Movement>>(
  (ref) => ref.read(movementDataSourceProvider).fetchMyMovements(),
);

/// A single movement's detail (posts + documents).
final movementDetailProvider = FutureProvider.autoDispose.family<MovementDetail, int>(
  (ref, id) => ref.read(movementDataSourceProvider).fetchDetail(id),
);
