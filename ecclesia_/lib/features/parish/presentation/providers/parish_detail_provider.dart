import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/parish_model.dart';
import '../../data/repositories/parish_repository_impl.dart';

/// Loads the full details of a parish by id, for the confirmation screen.
final parishDetailProvider = FutureProvider.autoDispose.family<ParishModel, int>(
  (ref, id) => ref.read(parishRepositoryProvider).fetchParish(id),
);
