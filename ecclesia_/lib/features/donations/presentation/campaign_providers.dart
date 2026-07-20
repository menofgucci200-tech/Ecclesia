import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../data/campaign.dart';

class CampaignRemoteDataSource {
  CampaignRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<Campaign>> fetch() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/campaigns');
      final data = response.data?['campaigns'] as List<dynamic>? ?? const [];
      return data.map((e) => Campaign.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Campaign> pledge(int id, int amount) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('/campaigns/$id/pledge', data: {'amount': amount});
      return Campaign.fromJson(response.data!['campaign'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

final campaignDataSourceProvider = Provider<CampaignRemoteDataSource>(
  (ref) => CampaignRemoteDataSource(ref.read(dioProvider)),
);

final campaignsProvider = FutureProvider.autoDispose<List<Campaign>>(
  (ref) => ref.read(campaignDataSourceProvider).fetch(),
);
