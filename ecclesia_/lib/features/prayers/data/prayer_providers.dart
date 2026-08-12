import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'prayer.dart';

class PrayerRemoteDataSource {
  PrayerRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<Prayer>> fetch() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/prayers');
      final data = response.data?['prayers'] as List<dynamic>? ?? const [];
      return data.map((e) => Prayer.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

final prayerDataSourceProvider = Provider<PrayerRemoteDataSource>(
  (ref) => PrayerRemoteDataSource(ref.read(dioProvider)),
);

/// All published spiritual content, fetched once and filtered by category in
/// the UI (the library is small).
final prayersProvider = FutureProvider.autoDispose<List<Prayer>>(
  (ref) => ref.read(prayerDataSourceProvider).fetch(),
);
