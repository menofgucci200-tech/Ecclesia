import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../models/home_data.dart';

/// Fetches the aggregated home payload (liturgy + parish schedule + headline).
class HomeRemoteDataSource {
  HomeRemoteDataSource(this._dio);

  final Dio _dio;

  Future<HomeData> fetchHome() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiConstants.home);
      return HomeData.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// The full agenda: major liturgical feasts + parish events (12 months).
  Future<List<AgendaEvent>> fetchAgenda() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiConstants.agenda);
      final data = response.data?['events'] as List<dynamic>? ?? const [];
      return data.map((e) => AgendaEvent.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
