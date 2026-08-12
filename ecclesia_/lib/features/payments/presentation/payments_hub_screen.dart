import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/message_card.dart';
import '../../home/presentation/theme/home_palette.dart';
import '../data/payment_models.dart';
import '../data/payment_providers.dart';
import 'my_payments_screen.dart';
import 'payment_form_screen.dart';

/// The "Paiements" tab: every payment a faithful can make to the parish
/// (demande de messe, quête, don, autre) via CinetPay.
class PaymentsHubScreen extends ConsumerWidget {
  const PaymentsHubScreen({super.key});

  static IconData iconFor(String type) => switch (type) {
        'mass_request' => Icons.church_outlined,
        'quete' => Icons.volunteer_activism_outlined,
        'don' => Icons.favorite_border,
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
            const Text('Paiements', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: HomePalette.navy))
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: .08, end: 0, duration: 280.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 2),
            const Text('Soutenez la vie de votre paroisse.', style: TextStyle(fontSize: 14, color: HomePalette.textBody))
                .animate()
                .fadeIn(duration: 280.ms, delay: 40.ms),
            const SizedBox(height: 14),
            _MyPaymentsBanner(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyPaymentsScreen()),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 60.ms).slideY(begin: .06, end: 0, duration: 300.ms, delay: 60.ms, curve: Curves.easeOutCubic),
            if (options.parishName != null) ...[
              const SizedBox(height: 12),
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
              ).animate().fadeIn(duration: 280.ms, delay: 100.ms),
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
              ).animate().fadeIn(duration: 280.ms, delay: 120.ms),
            ],
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                for (final (i, t) in options.types.indexed)
                  _PaymentTypeCard(
                    option: t,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PaymentFormScreen(option: t, options: options)),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 280.ms, delay: (140 + i * 60).ms)
                      .slideY(begin: .08, end: 0, duration: 280.ms, delay: (140 + i * 60).ms, curve: Curves.easeOutCubic),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A prominent, always-visible entry point to the payment history & receipts
/// — deliberately more discoverable than a small icon button.
class _MyPaymentsBanner extends StatefulWidget {
  const _MyPaymentsBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_MyPaymentsBanner> createState() => _MyPaymentsBannerState();
}

class _MyPaymentsBannerState extends State<_MyPaymentsBanner> {
  double _scale = 1;

  void _setPressed(bool pressed) => setState(() => _scale = pressed ? 0.98 : 1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [HomePalette.navy, Color(0xFF1A6B9E)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: HomePalette.navy.withValues(alpha: .22), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mes paiements', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                    SizedBox(height: 2),
                    Text('Historique et reçus de vos paiements', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentTypeCard extends StatefulWidget {
  const _PaymentTypeCard({required this.option, required this.onTap});

  final PaymentTypeOption option;
  final VoidCallback onTap;

  @override
  State<_PaymentTypeCard> createState() => _PaymentTypeCardState();
}

class _PaymentTypeCardState extends State<_PaymentTypeCard> {
  double _scale = 1;

  void _setPressed(bool pressed) => setState(() => _scale = pressed ? 0.96 : 1);

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onTap();
          },
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
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
                  child: Icon(PaymentsHubScreen.iconFor(widget.option.type), color: HomePalette.navy, size: 24),
                ),
                const Spacer(),
                Text(widget.option.label, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: HomePalette.navy)),
                const SizedBox(height: 3),
                Text(widget.option.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: HomePalette.textBody, height: 1.35)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
