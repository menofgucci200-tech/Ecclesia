import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../home/presentation/theme/home_palette.dart';
import '../data/campaign.dart';
import 'campaign_providers.dart';

class DonationsScreen extends ConsumerWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(campaignsProvider);
    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(
        backgroundColor: HomePalette.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Dons & collectes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: HomePalette.navy)),
        error: (e, _) => Center(child: TextButton(onPressed: () => ref.invalidate(campaignsProvider), child: const Text('Réessayer'))),
        data: (campaigns) {
          if (campaigns.isEmpty) {
            return const Center(child: Text('Aucune collecte en cours.', style: TextStyle(color: HomePalette.textBody)));
          }
          return RefreshIndicator(
            color: HomePalette.navy,
            onRefresh: () async => ref.invalidate(campaignsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: campaigns.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) => CampaignCard(campaign: campaigns[i]),
            ),
          );
        },
      ),
    );
  }
}

/// A campaign card with progress bar and a "Donner" action (pledge).
class CampaignCard extends ConsumerWidget {
  const CampaignCard({super.key, required this.campaign});

  final Campaign campaign;

  String _fmt(int v) => v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ');

  Future<void> _donate(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final amount = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Faire un don', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: HomePalette.navy)),
            const SizedBox(height: 4),
            Text(campaign.title, style: const TextStyle(fontSize: 13, color: HomePalette.textBody)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Montant (F CFA)',
                filled: true,
                fillColor: HomePalette.screenBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [1000, 2000, 5000, 10000]
                  .map((v) => ActionChip(label: Text('$v F'), onPressed: () => controller.text = '$v'))
                  .toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: HomePalette.gold, foregroundColor: HomePalette.navy, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () => Navigator.of(ctx).pop(int.tryParse(controller.text.trim())),
                child: const Text('Confirmer ma promesse de don', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Le paiement en ligne sera bientôt disponible. Votre promesse est enregistrée.',
                style: TextStyle(fontSize: 11.5, color: HomePalette.textMuted)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (amount == null || amount < 100) return;

    try {
      await ref.read(campaignDataSourceProvider).pledge(campaign.id, amount);
      ref.invalidate(campaignsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Merci ! Votre promesse est enregistrée. 🙏'), behavior: SnackBarBehavior.floating));
      }
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: HomePalette.cardBg, borderRadius: BorderRadius.circular(18), border: Border.all(color: HomePalette.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (campaign.imageUrl != null)
            Image.network(campaign.imageUrl!, height: 140, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: HomePalette.gold.withValues(alpha: .15), borderRadius: BorderRadius.circular(8)),
                  child: Text(campaign.typeLabel.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF8A6D1B), letterSpacing: .5)),
                ),
                const SizedBox(height: 10),
                Text(campaign.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: HomePalette.navy)),
                if ((campaign.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(campaign.description!, style: const TextStyle(fontSize: 13, color: HomePalette.textBody, height: 1.5)),
                ],
                if (campaign.targetAmount != null) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: campaign.progress / 100,
                      minHeight: 8,
                      backgroundColor: HomePalette.screenBg,
                      valueColor: const AlwaysStoppedAnimation(HomePalette.gold),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_fmt(campaign.collectedAmount)} F', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: HomePalette.navy)),
                      Text('Objectif ${_fmt(campaign.targetAmount!)} F', style: const TextStyle(fontSize: 12, color: HomePalette.textBody)),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: HomePalette.navy, padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () => _donate(context, ref),
                    icon: const Icon(Icons.volunteer_activism_outlined, size: 18),
                    label: const Text('Faire un don', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
