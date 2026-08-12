import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'intention.dart';

class IntentionDataSource {
  IntentionDataSource(this._dio);
  final Dio _dio;

  Future<IntentionsResult> fetch() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/intentions');
      final data = res.data?['intentions'] as List<dynamic>? ?? const [];
      return IntentionsResult(
        items: data.map((e) => Intention.fromJson(e as Map<String, dynamic>)).toList(),
        needsParish: res.data?['needs_parish'] as bool? ?? false,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Intention> create(String intention, bool isAnonymous) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>('/intentions', data: {
        'intention': intention,
        'is_anonymous': isAnonymous,
      });
      return Intention.fromJson(res.data!['intention'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<int> pray(int id) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>('/intentions/$id/pray');
      return (res.data?['prayers_count'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete<void>('/intentions/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final intentionDataSourceProvider = Provider<IntentionDataSource>(
  (ref) => IntentionDataSource(ref.read(dioProvider)),
);
