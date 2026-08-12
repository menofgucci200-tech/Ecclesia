import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'payment_models.dart';

class PaymentDataSource {
  PaymentDataSource(this._dio);
  final Dio _dio;

  Future<PaymentOptions> options() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/payments/options');
      return PaymentOptions.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PaymentInit> create({
    required String type,
    required int amount,
    String? note,
    String? intentionType,
    String? intention,
    String? date,
    String? title,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>('/payments', data: {
        'type': type,
        'amount': amount,
        if (note != null && note.isNotEmpty) 'note': note,
        if (intentionType != null) 'intention_type': intentionType,
        if (intention != null && intention.isNotEmpty) 'intention': intention,
        if (date != null) 'date': date,
        if (title != null && title.isNotEmpty) 'title': title,
      });
      return PaymentInit(
        reference: res.data!['reference'] as String,
        paymentUrl: res.data!['payment_url'] as String,
      );
    } on DioException catch (e) {
      // A 503 carries a human message (e.g. "paiement pas encore activé").
      final data = e.response?.data;
      if (e.response?.statusCode == 503 && data is Map && data['message'] is String) {
        throw UnknownException(data['message'] as String);
      }
      throw ApiException.fromDio(e);
    }
  }

  Future<PaymentRecord> status(String reference) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/payments/$reference');
      return PaymentRecord.fromJson(res.data!['payment'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<PaymentRecord>> mine() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/payments/mine');
      final data = res.data?['payments'] as List<dynamic>? ?? const [];
      return data.map((e) => PaymentRecord.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final paymentDataSourceProvider = Provider<PaymentDataSource>(
  (ref) => PaymentDataSource(ref.read(dioProvider)),
);

final paymentOptionsProvider = FutureProvider.autoDispose<PaymentOptions>(
  (ref) => ref.read(paymentDataSourceProvider).options(),
);

final myPaymentsProvider = FutureProvider.autoDispose<List<PaymentRecord>>(
  (ref) => ref.read(paymentDataSourceProvider).mine(),
);
