import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/home_provider.dart';
import '../theme/home_palette.dart';
import 'liturgy_screen.dart';

/// Loads today's liturgy (from AELF) and shows the [LiturgyScreen].
class LiturgyTodayScreen extends ConsumerWidget {
  const LiturgyTodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final key = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final async = ref.watch(liturgyForDateProvider(key));

    return async.when(
      loading: () => const Scaffold(
        backgroundColor: HomePalette.screenBg,
        body: Center(child: CircularProgressIndicator(color: HomePalette.navy)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(backgroundColor: HomePalette.navy, foregroundColor: Colors.white),
        body: Center(child: TextButton(onPressed: () => ref.invalidate(liturgyForDateProvider(key)), child: const Text('Réessayer'))),
      ),
      data: (liturgy) => liturgy == null
          ? Scaffold(
              appBar: AppBar(backgroundColor: HomePalette.navy, foregroundColor: Colors.white, title: const Text('Liturgie')),
              body: const Center(child: Text('Liturgie indisponible.')),
            )
          : LiturgyScreen(liturgy: liturgy),
    );
  }
}
