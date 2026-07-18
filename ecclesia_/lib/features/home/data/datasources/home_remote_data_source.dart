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
}
