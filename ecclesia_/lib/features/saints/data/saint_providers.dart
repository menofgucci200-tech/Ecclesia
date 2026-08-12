import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'saint.dart';

class SaintDataSource {
  SaintDataSource(this._dio);
  final Dio _dio;

  /// [date] is `YYYY-MM-DD`. Returns null when no saint is celebrated that day.
  Future<Saint?> forDate(String date) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/saints/$date');
      final data = res.data?['saint'];
      return data == null ? null : Saint.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final saintDataSourceProvider = Provider<SaintDataSource>(
  (ref) => SaintDataSource(ref.read(dioProvider)),
);

final saintProvider = FutureProvider.autoDispose.family<Saint?, String>(
  (ref, date) => ref.read(saintDataSourceProvider).forDate(date),
);
