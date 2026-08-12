import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/skeleton.dart';
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
        body: Padding(
          padding: EdgeInsets.all(20),
          child: SkeletonParagraph(lines: 6),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: HomePalette.screenBg,
        appBar: AppBar(backgroundColor: HomePalette.navy, foregroundColor: Colors.white),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ErrorState(
            message: 'Liturgie indisponible.',
            onRetry: () => ref.invalidate(liturgyForDateProvider(key)),
          ),
        ),
      ),
      data: (liturgy) => liturgy == null
          ? Scaffold(
              backgroundColor: HomePalette.screenBg,
              appBar: AppBar(backgroundColor: HomePalette.navy, foregroundColor: Colors.white, title: const Text('Liturgie')),
              body: const Padding(
                padding: EdgeInsets.all(20),
                child: EmptyState(message: 'Liturgie indisponible.', icon: Icons.menu_book_outlined),
              ),
            )
          : LiturgyScreen(liturgy: liturgy),
    );
  }
}
