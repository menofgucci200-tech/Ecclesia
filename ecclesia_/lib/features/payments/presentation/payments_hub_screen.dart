import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/message_card.dart';
import '../../home/presentation/theme/home_palette.dart';
import '../data/payment_models.dart';
import '../data/payment_providers.dart';
import 'my_payments_screen.dart';
import 'payment_form_screen.dart';

/// The "Paiements" tab: every payment a faithful can make to the parish
/// (mass request, quête, don, casuel, denier, cierges) via CinetPay.
class PaymentsHubScreen extends ConsumerWidget {
  const PaymentsHubScreen({super.key});

  static IconData iconFor(String type) => switch (type) {
        'mass_request' => Icons.church_outlined,
        'quete' => Icons.volunteer_activism_outlined,
        'don' => Icons.favorite_border,
        'caritas' => Icons.handshake_outlined,
        'casuel' => Icons.celebration_outlined,
        'denier' => Icons.account_balance_outlined,
        'cierge' => Icons.local_fire_department_outlined,
        'autre' => Icons.more_horiz,
        _ => Icons.payments_outlined,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(paymentOptionsProvider);

    return Container(
      color: HomePalette.screenBg,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: HomePalette.navy)),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: MessageCard.fromException(
              e is ApiException ? e : const UnknownException('Une erreur est survenue.'),
              onRetry: () => ref.invalidate(paymentOptionsProvider),
            ),
          ),
        ),
        data: (options) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paiements', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: HomePalette.navy)),
                      SizedBox(height: 2),
                      Text('Soutenez la vie de votre paroisse.', style: TextStyle(fontSize: 14, color: HomePalette.textBody)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyPaymentsScreen()),
                  ),
                  icon: const Icon(Icons.receipt_long_outlined, color: HomePalette.navy),
                  tooltip: 'Mes paiements',
                ),
              ],
            ),
            if (options.parishName != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: HomePalette.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.church, size: 18, color: HomePalette.navy),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Bénéficiaire : ${options.parishName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HomePalette.navy))),
                  ],
                ),
              ),
            ],
            if (!options.configured) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE9CE8A)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Color(0xFF8A6D1B), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Votre paroisse n\'a pas encore activé les paiements Mobile Money. Vous pouvez déjà découvrir les options.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF8A6D1B), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: options.types
                  .map((t) => _PaymentTypeCard(
                        option: t,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PaymentFormScreen(option: t, options: options)),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTypeCard extends StatelessWidget {
  const _PaymentTypeCard({required this.option, required this.onTap});

  final PaymentTypeOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HomePalette.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: HomePalette.navy.withValues(alpha: .08), borderRadius: BorderRadius.circular(13)),
                child: Icon(PaymentsHubScreen.iconFor(option.type), color: HomePalette.navy, size: 24),
              ),
              const Spacer(),
              Text(option.label, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: HomePalette.navy)),
              const SizedBox(height: 3),
              Text(option.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: HomePalette.textBody, height: 1.35)),
            ],
          ),
        ),
      ),
    );
  }
}
