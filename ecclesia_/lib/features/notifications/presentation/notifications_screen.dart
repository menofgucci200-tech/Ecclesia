import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/skeleton.dart';
import '../../announcement/presentation/announcement_visuals.dart';
import '../../home/presentation/theme/home_palette.dart';
import '../data/notification_models.dart';
import '../data/notification_providers.dart';

/// The notification center opened from the app bar's bell icon: the parish
/// feed, most recent first, with unread items highlighted. Opening this
/// screen marks everything currently visible as read.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Mark-as-read fires once the list has had a chance to render, then
    // clears the bell badge for the rest of the session.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(notificationDataSourceProvider).markRead();
      } catch (_) {
        // Best-effort: the badge just won't clear this time.
      }
      if (mounted) ref.invalidate(unreadNotificationsCountProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(notificationsListProvider);

    return Scaffold(
      backgroundColor: HomePalette.screenBg,
      appBar: AppBar(title: const Text('Notifications')),
      body: RefreshIndicator(
        color: HomePalette.navy,
        onRefresh: () async => ref.invalidate(notificationsListProvider),
        child: async.when(
          loading: () => const Padding(padding: EdgeInsets.all(16), child: SkeletonList()),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(20),
            child: ErrorState(
              message: e is ApiException ? e.message : 'Impossible de charger les notifications.',
              onRetry: () => ref.invalidate(notificationsListProvider),
            ),
          ),
          data: (items) => items.isEmpty
              ? const EmptyState(message: 'Aucune notification pour le moment.', icon: Icons.notifications_none)
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _NotificationTile(item: items[i]),
                ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});
  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final visual = AnnouncementVisual.forCategory(item.category);

    return Material(
      color: item.read ? Colors.white : const Color(0xFFF3F8FF),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => HapticFeedback.selectionClick(),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: item.read ? HomePalette.cardBorder : visual.gradient.first.withValues(alpha: .3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: visual.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: Icon(visual.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: item.read ? FontWeight.w600 : FontWeight.w800,
                              color: HomePalette.navy,
                            ),
                          ),
                        ),
                        if (!item.read) ...[
                          const SizedBox(width: 8),
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: HomePalette.red, shape: BoxShape.circle)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, color: HomePalette.textBody, height: 1.35),
                    ),
                    const SizedBox(height: 6),
                    Text(item.relativeLabel, style: const TextStyle(fontSize: 11, color: HomePalette.textMuted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
