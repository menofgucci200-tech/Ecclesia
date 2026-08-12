import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'notification_models.dart';

class NotificationDataSource {
  NotificationDataSource(this._dio);
  final Dio _dio;

  Future<List<NotificationItem>> list({int perPage = 20}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        ApiConstants.notifications,
        queryParameters: {'per_page': perPage},
      );
      final data = res.data?['data'] as List<dynamic>? ?? const [];
      return data.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<int> unreadCount() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiConstants.notificationsUnreadCount);
      return (res.data?['count'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> markRead() async {
    try {
      await _dio.post<void>(ApiConstants.notificationsMarkRead);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final notificationDataSourceProvider = Provider<NotificationDataSource>(
  (ref) => NotificationDataSource(ref.read(dioProvider)),
);

/// Badge count shown on the bell icon. Auto-disposed so it refreshes
/// whenever the home app bar rebuilds (e.g. pulling the feed).
final unreadNotificationsCountProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.read(notificationDataSourceProvider).unreadCount(),
);

final notificationsListProvider = FutureProvider.autoDispose<List<NotificationItem>>(
  (ref) => ref.read(notificationDataSourceProvider).list(),
);
