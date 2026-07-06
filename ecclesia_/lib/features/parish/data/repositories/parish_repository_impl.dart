import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/parish_repository.dart';
import '../datasources/parish_remote_data_source.dart';
import '../models/paginated_parishes.dart';
import '../models/parish_model.dart';

class ParishRepositoryImpl implements ParishRepository {
  ParishRepositoryImpl(this._remote);

  final ParishRemoteDataSource _remote;

  @override
  Future<PaginatedParishes> fetchParishes({int page = 1, int perPage = 20}) =>
      _remote.fetchParishes(page: page, perPage: perPage);

  @override
  Future<PaginatedParishes> searchParishes({
    required String query,
    int page = 1,
    int perPage = 20,
  }) =>
      _remote.searchParishes(query: query, page: page, perPage: perPage);

  @override
  Future<ParishModel> fetchParish(int id) => _remote.fetchParish(id);

  @override
  Future<ParishModel> associate(int parishId) => _remote.associate(parishId);

  @override
  Future<ParishModel?> fetchCurrent() => _remote.fetchCurrent();
}

final parishRemoteDataSourceProvider = Provider<ParishRemoteDataSource>((ref) {
  return ParishRemoteDataSource(ref.read(dioProvider));
});

final parishRepositoryProvider = Provider<ParishRepository>((ref) {
  return ParishRepositoryImpl(ref.read(parishRemoteDataSourceProvider));
});
