import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/cached_fetch.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/cache_service.dart';
import '../data/campaign.dart';

class CampaignRemoteDataSource {
  CampaignRemoteDataSource(this._dio, this._cache);
  final Dio _dio;
  final CacheService _cache;

  Future<List<Campaign>> fetch() async {
    final json = await fetchJsonWithCache(
      cache: _cache,
      cacheKey: 'campaigns',
      request: () => _dio.get<Map<String, dynamic>>('/campaigns'),
    );
    final data = json['campaigns'] as List<dynamic>? ?? const [];
    return data.map((e) => Campaign.fromJson(e as Map<String, dynamic>)).toList();
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
  (ref) => CampaignRemoteDataSource(ref.read(dioProvider), ref.read(cacheServiceProvider)),
);

final campaignsProvider = FutureProvider.autoDispose<List<Campaign>>(
  (ref) => ref.read(campaignDataSourceProvider).fetch(),
);
