import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../home/presentation/theme/home_palette.dart';
import '../data/payment_models.dart';
import '../data/payment_providers.dart';

/// Follows a payment after the CinetPay page has been opened: polls the backend
/// (which is updated by CinetPay's webhook) until the status is final.
class PaymentStatusScreen extends ConsumerStatefulWidget {
  const PaymentStatusScreen({super.key, required this.reference, required this.paymentUrl});

  final String reference;
  final String paymentUrl;

  @override
  ConsumerState<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends ConsumerState<PaymentStatusScreen> {
  Timer? _timer;
  PaymentRecord? _record;
  bool _checking = true;
  int _attempts = 0;

  static const _maxAttempts = 40; // ~40 × 4s ≈ 2.5 min

  @override
  void initState() {
    super.initState();
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    if (!mounted) return;
    setState(() => _checking = true);
    _attempts++;
    try {
      final record = await ref.read(paymentDataSourceProvider).status(widget.reference);
      if (!mounted) return;
      setState(() => _record = record);
      if (record.isFinal || _attempts >= _maxAttempts) {
        _timer?.cancel();
      }
    } catch (_) {
      // Ignore transient errors; the periodic timer will retry.
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _openPayment() async {
    await launchUrl(Uri.parse(widget.paymentUrl), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final record = _record;
    final paid = record?.isPaid ?? false;
    final failed = record != null && record.isFinal && !paid;

    return PopScope(
      canPop: record?.isFinal ?? false,
      child: Scaffold(
        backgroundColor: HomePalette.navy,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (paid)
                  _icon(Icons.check_rounded, HomePalette.gold)
                else if (failed)
                  _icon(Icons.close_rounded, const Color(0xFFE0526B))
                else
                  const SizedBox(
                    width: 64, height: 64,
                    child: CircularProgressIndicator(color: HomePalette.gold, strokeWidth: 3),
                  ),
                const SizedBox(height: 26),
                Text(
                  paid
                      ? 'Paiement confirmé 🙏'
                      : failed
                          ? 'Paiement non abouti'
                          : 'En attente de confirmation…',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  paid
                      ? 'Merci pour votre offrande de ${record!.amount} F. Elle a bien été reçue.'
                      : failed
                          ? 'Le paiement n\'a pas pu être finalisé. Vous pouvez réessayer.'
                          : 'Terminez le paiement dans la page ouverte. Le statut se met à jour automatiquement ici.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 14.5, height: 1.55),
                ),
                const SizedBox(height: 10),
                Text('Réf. ${widget.reference}',
                    style: TextStyle(color: Colors.white.withValues(alpha: .5), fontSize: 12)),
                const SizedBox(height: 34),
                if (paid || failed)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: HomePalette.gold,
                        foregroundColor: HomePalette.navy,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () => Navigator.of(context).pop(paid),
                      child: Text(paid ? 'Terminer' : 'Fermer', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  )
                else ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: HomePalette.gold,
                        foregroundColor: HomePalette.navy,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _checking ? null : _poll,
                      child: const Text('J\'ai payé — vérifier', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _openPayment,
                    child: Text('Rouvrir la page de paiement',
                        style: TextStyle(color: Colors.white.withValues(alpha: .9))),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _icon(IconData icon, Color color) => Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: HomePalette.navy, size: 48),
      );
}
