import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'nearby_parish_model.dart';

class DiscoverDataSource {
  DiscoverDataSource(this._dio);
  final Dio _dio;

  Future<List<NearbyParish>> fetchNearby({required double lat, required double lng, double radiusKm = 50}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        ApiConstants.parishesNearby,
        queryParameters: {'lat': lat, 'lng': lng, 'radius_km': radiusKm},
      );
      final data = res.data?['data'] as List<dynamic>? ?? const [];
      return data.map((e) => NearbyParish.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final discoverDataSourceProvider = Provider<DiscoverDataSource>(
  (ref) => DiscoverDataSource(ref.read(dioProvider)),
);

/// Parishes near a given point, distance-sorted. Keyed by (lat, lng, radius)
/// so moving the map or changing the radius fetches fresh results.
final nearbyParishesProvider = FutureProvider.autoDispose.family<List<NearbyParish>, ({double lat, double lng, double radiusKm})>(
  (ref, params) => ref.read(discoverDataSourceProvider).fetchNearby(lat: params.lat, lng: params.lng, radiusKm: params.radiusKm),
);
