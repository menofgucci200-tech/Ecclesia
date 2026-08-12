import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../home/presentation/theme/home_palette.dart';
import '../data/intention.dart';
import '../data/intention_providers.dart';

/// The parish "prayer intentions" wall: read others' intentions, tap « Je prie »,
/// and share your own (optionally anonymously).
class IntentionsScreen extends ConsumerStatefulWidget {
  const IntentionsScreen({super.key});

  @override
  ConsumerState<IntentionsScreen> createState() => _IntentionsScreenState();
}

class _IntentionsScreenState extends ConsumerState<IntentionsScreen> {
  List<Intention>? _items;
  bool _loading = true;
  bool _needsParish = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ref.read(intentionDataSourceProvider).fetch();
      if (!mounted) return;
      setState(() {
        _items = res.items;
        _needsParish = res.needsParish;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _pray(Intention it) async {
    if (it.hasPrayed) return;
    // Optimistic update.
    setState(() {
      _items = _items!
          .map((e) => e.id == it.id ? e.copyWith(hasPrayed: true, prayersCount: e.prayersCount + 1) : e)
          .toList();
    });
    try {
      final count = await ref.read(intentionDataSourceProvider).pray(it.id);
      if (!mounted) return;
      setState(() {
        _items = _items!.map((e) => e.id == it.id ? e.copyWith(prayersCount: count) : e).toList();
      });
    } catch (_) {
      // Revert on failure.
      if (!mounted) return;
      setState(() {
        _items = _items!
            .map((e) => e.id == it.id ? e.copyWith(hasPrayed: false, prayersCount: e.prayersCount - 1) : e)
            .toList();
      });
    }
  }

  Future<void> _delete(Intention it) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: const Text('Retirer votre intention du mur ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _items = _items!.where((e) => e.id != it.id).toList());
    try {
      await ref.read(intentionDataSourceProvider).delete(it.id);
    } catch (_) {
      _load();
    }
  }

  Future<void> _share() async {
    final controller = TextEditingController();
    var anonymous = false;
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Partager une intention', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: HomePalette.navy)),
              const SizedBox(height: 4),
              const Text('Votre communauté priera pour vous.', style: TextStyle(fontSize: 13, color: HomePalette.textBody)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Ex. Priez pour la santé de ma mère…',
                  filled: true,
                  fillColor: HomePalette.screenBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: anonymous,
                activeThumbColor: HomePalette.navy,
                title: const Text('Rester anonyme', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                onChanged: (v) => setSheet(() => anonymous = v),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: HomePalette.navy, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Publier', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );

    if (result != true) return;
    final text = controller.text.trim();
    if (text.length < 3) return;
    try {
      final created = await ref.read(intentionDataSourceProvider).create(text, anonymous);
      if (!mounted) return;
      setState(() => _items = [created, ...?_items]);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(
        backgroundColor: HomePalette.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Intentions de prière', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      floatingActionButton: (_needsParish)
          ? null
          : FloatingActionButton.extended(
              backgroundColor: HomePalette.gold,
              foregroundColor: HomePalette.navy,
              onPressed: _share,
              icon: const Icon(Icons.add),
              label: const Text('Partager', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: HomePalette.navy));
    if (_error != null) {
      return Center(
        child: TextButton(onPressed: _load, child: Text(_error is ApiException ? (_error as ApiException).message : 'Réessayer')),
      );
    }
    if (_needsParish) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Rejoignez une paroisse pour partager et prier des intentions.',
              textAlign: TextAlign.center, style: TextStyle(color: HomePalette.textBody, height: 1.5)),
        ),
      );
    }
    final items = _items ?? const <Intention>[];
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Aucune intention pour l\'instant.\nSoyez le premier à en partager une 🙏',
              textAlign: TextAlign.center, style: TextStyle(color: HomePalette.textBody, height: 1.5)),
        ),
      );
    }
    return RefreshIndicator(
      color: HomePalette.navy,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _IntentionCard(intention: items[i], onPray: () => _pray(items[i]), onDelete: () => _delete(items[i])),
      ),
    );
  }
}

class _IntentionCard extends StatelessWidget {
  const _IntentionCard({required this.intention, required this.onPray, required this.onDelete});

  final Intention intention;
  final VoidCallback onPray;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomePalette.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HomePalette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: HomePalette.navy.withValues(alpha: .1),
                child: Icon(intention.isAnonymous ? Icons.visibility_off_outlined : Icons.person_outline, size: 16, color: HomePalette.navy),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(intention.authorName, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: HomePalette.navy)),
              ),
              if (intention.isMine)
                InkWell(
                  onTap: onDelete,
                  child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.delete_outline, size: 18, color: HomePalette.textMuted)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(intention.intention, style: const TextStyle(fontSize: 15, height: 1.55, color: HomePalette.textBody)),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('🙏 ${intention.prayersCount}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: HomePalette.navy)),
              const Spacer(),
              FilledButton.icon(
                onPressed: intention.hasPrayed ? null : onPray,
                style: FilledButton.styleFrom(
                  backgroundColor: intention.hasPrayed ? HomePalette.screenBg : HomePalette.navy,
                  foregroundColor: intention.hasPrayed ? HomePalette.navy : Colors.white,
                  disabledBackgroundColor: HomePalette.screenBg,
                  disabledForegroundColor: HomePalette.navy,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  visualDensity: VisualDensity.compact,
                ),
                icon: Icon(intention.hasPrayed ? Icons.check : Icons.volunteer_activism_outlined, size: 16),
                label: Text(intention.hasPrayed ? 'Vous priez' : 'Je prie', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
