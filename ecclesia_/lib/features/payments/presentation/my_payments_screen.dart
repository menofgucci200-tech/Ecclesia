import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/message_card.dart';
import '../../home/presentation/theme/home_palette.dart';
import '../data/payment_models.dart';
import '../data/payment_providers.dart';
import 'payments_hub_screen.dart';

/// The faithful's payment history with statuses.
class MyPaymentsScreen extends ConsumerWidget {
  const MyPaymentsScreen({super.key});

  static String _fmt(int v) => v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ');

  static ({Color bg, Color fg, String label}) _badge(String status, String label) {
    switch (status) {
      case 'paid':
        return (bg: const Color(0xFFE6F6EC), fg: const Color(0xFF1B8A4B), label: label);
      case 'pending':
        return (bg: const Color(0xFFFFF4DC), fg: const Color(0xFF8A6D1B), label: label);
      default:
        return (bg: const Color(0xFFFCE8EC), fg: const Color(0xFFC0334D), label: label);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myPaymentsProvider);

    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(
        backgroundColor: HomePalette.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Mes paiements', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: HomePalette.navy)),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: MessageCard.fromException(
              e is ApiException ? e : const UnknownException('Une erreur est survenue.'),
              onRetry: () => ref.invalidate(myPaymentsProvider),
            ),
          ),
        ),
        data: (payments) {
          if (payments.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Aucun paiement pour l\'instant.', style: TextStyle(color: HomePalette.textBody)),
              ),
            );
          }
          return RefreshIndicator(
            color: HomePalette.navy,
            onRefresh: () async => ref.invalidate(myPaymentsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _PaymentRow(payment: payments[i]),
            ),
          );
        },
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});

  final PaymentRecord payment;

  @override
  Widget build(BuildContext context) {
    final badge = MyPaymentsScreen._badge(payment.status, payment.statusLabel);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HomePalette.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: HomePalette.navy.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)),
            child: Icon(PaymentsHubScreen.iconFor(payment.type), color: HomePalette.navy, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.typeLabel, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: HomePalette.navy)),
                const SizedBox(height: 2),
                Text('${MyPaymentsScreen._fmt(payment.amount)} F', style: const TextStyle(fontSize: 13, color: HomePalette.textBody)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: badge.bg, borderRadius: BorderRadius.circular(8)),
            child: Text(badge.label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: badge.fg)),
          ),
        ],
      ),
    );
  }
}
