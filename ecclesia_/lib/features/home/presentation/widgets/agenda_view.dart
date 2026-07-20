import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/home_data.dart';
import '../providers/home_provider.dart';
import '../screens/liturgy_screen.dart';
import '../theme/home_palette.dart';
import '../theme/liturgical_colors.dart';

/// The "Agenda" tab: a real monthly calendar (Google-Agenda style) with
/// liturgical-colour dots, this week's events, and a day-detail sheet.
class AgendaView extends ConsumerStatefulWidget {
  const AgendaView({super.key, this.seasonColor = HomePalette.navy});

  final Color seasonColor;

  @override
  ConsumerState<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends ConsumerState<AgendaView> {
  static const _months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];
  static const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  String _key(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(agendaProvider);

    return async.when(
      loading: () => Center(child: CircularProgressIndicator(color: widget.seasonColor)),
      error: (e, _) => _Message(icon: Icons.wifi_off_rounded, text: 'Impossible de charger l\'agenda.', onRetry: () => ref.invalidate(agendaProvider)),
      data: (events) {
        // Index events by day.
        final byDay = <String, List<AgendaEvent>>{};
        for (final e in events) {
          byDay.putIfAbsent(_key(e.date), () => []).add(e);
        }

        // This week's events (Mon..Sun of the current real week).
        final now = DateTime.now();
        final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        final weekEvents = events.where((e) {
          final d = DateTime(e.date.year, e.date.month, e.date.day);
          return !d.isBefore(monday) && !d.isAfter(sunday);
        }).toList();

        return RefreshIndicator(
          color: widget.seasonColor,
          onRefresh: () async => ref.invalidate(agendaProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
            children: [
              _calendarCard(byDay),
              const SizedBox(height: 16),
              _legend(),
              const SizedBox(height: 22),
              Text('Cette semaine', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: HomePalette.navy)),
              const SizedBox(height: 4),
              Text('${monday.day} – ${sunday.day} ${_months[sunday.month - 1].toLowerCase()}',
                  style: const TextStyle(fontSize: 12, color: HomePalette.textBody)),
              const SizedBox(height: 12),
              if (weekEvents.isEmpty)
                const Text('Aucun événement cette semaine.', style: TextStyle(fontSize: 13, color: HomePalette.textBody))
              else
                ...weekEvents.map((e) => _weekTile(e)),
            ],
          ),
        );
      },
    );
  }

  Widget _calendarCard(Map<String, List<AgendaEvent>> byDay) {
    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = first.weekday - 1; // Monday-first
    final totalCells = ((leading + daysInMonth) / 7).ceil() * 7;
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HomePalette.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomePalette.cardBorder),
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            children: [
              _navBtn(Icons.chevron_left, () => setState(() => _month = DateTime(_month.year, _month.month - 1))),
              Expanded(
                child: Text(
                  '${_months[_month.month - 1]} ${_month.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: widget.seasonColor),
                ),
              ),
              _navBtn(Icons.chevron_right, () => setState(() => _month = DateTime(_month.year, _month.month + 1))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: _weekdays
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: HomePalette.textMuted)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: .78),
            itemBuilder: (context, i) {
              final dayNum = i - leading + 1;
              if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox.shrink();

              final date = DateTime(_month.year, _month.month, dayNum);
              final dayEvents = byDay[_key(date)] ?? const [];
              final isToday = date.year == today.year && date.month == today.month && date.day == today.day;

              return _DayCell(
                day: dayNum,
                isToday: isToday,
                seasonColor: widget.seasonColor,
                dots: dayEvents
                    .take(3)
                    .map((e) => LiturgicalColors.dot(isParish: e.isParish, liturgicalColor: e.color))
                    .toList(),
                onTap: dayEvents.isEmpty ? null : () => _showDay(date, dayEvents),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 22, color: HomePalette.textAuthor)),
      );

  Widget _legend() {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: LiturgicalColors.legend
          .map((e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 9, height: 9, decoration: BoxDecoration(color: e.$1, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(e.$2, style: const TextStyle(fontSize: 11, color: HomePalette.textBody)),
                ],
              ))
          .toList(),
    );
  }

  Widget _weekTile(AgendaEvent e) {
    final color = LiturgicalColors.dot(isParish: e.isParish, liturgicalColor: e.color);
    return InkWell(
      onTap: () => _showDay(e.date, [e]),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: HomePalette.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HomePalette.cardBorder),
        ),
        child: Row(
          children: [
            Container(width: 4, height: 38, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2A3646))),
                  const SizedBox(height: 2),
                  Text(
                    '${_weekdayLong(e.date)} ${e.date.day}${e.time != null ? ' · ${e.time}' : ''}${e.isParish ? '' : ' · ${e.subtitle ?? ''}'}',
                    style: const TextStyle(fontSize: 12, color: HomePalette.textBody),
                  ),
                ],
              ),
            ),
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }

  void _showDay(DateTime date, List<AgendaEvent> events) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _DayDetailSheet(date: date, events: events, seasonColor: widget.seasonColor),
    );
  }

  static const _daysLong = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  String _weekdayLong(DateTime d) => _daysLong[d.weekday - 1];
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.isToday, required this.dots, required this.seasonColor, this.onTap});

  final int day;
  final bool isToday;
  final List<Color> dots;
  final Color seasonColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isToday ? seasonColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                color: isToday ? Colors.white : const Color(0xFF3A4657),
              ),
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            height: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: dots
                  .map((c) => Container(
                        width: 5, height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayDetailSheet extends ConsumerWidget {
  const _DayDetailSheet({required this.date, required this.events, required this.seasonColor});

  final DateTime date;
  final List<AgendaEvent> events;
  final Color seasonColor;

  static const _days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  static const _months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  String get _dateStr => '${date.day} ${_months[date.month - 1]} ${date.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFeast = events.any((e) => !e.isParish);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: HomePalette.cardBorder, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Text(_days[date.weekday - 1], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: seasonColor)),
            Text(_dateStr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: HomePalette.navy)),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: events.map((e) => _EventDetail(event: e)).toList(),
                ),
              ),
            ),
            if (hasFeast) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: seasonColor, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => _LiturgyByDateScreen(date: date),
                    ));
                  },
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: const Text('Voir les lectures du jour'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EventDetail extends StatelessWidget {
  const _EventDetail({required this.event});

  final AgendaEvent event;

  @override
  Widget build(BuildContext context) {
    final color = LiturgicalColors.dot(isParish: event.isParish, liturgicalColor: event.color);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(event.isParish ? Icons.groups_outlined : Icons.church_outlined, size: 15, color: color),
              const SizedBox(width: 5),
              Text(event.isParish ? 'Événement paroisse' : (event.subtitle ?? 'Fête'),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          Text(event.title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: Color(0xFF2A3646), height: 1.25)),
          if (event.time != null || event.location != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (event.time != null) ...[
                  const Icon(Icons.schedule, size: 14, color: HomePalette.textBody),
                  const SizedBox(width: 4),
                  Text(event.time!, style: const TextStyle(fontSize: 12.5, color: HomePalette.textBody)),
                  const SizedBox(width: 12),
                ],
                if (event.location != null) ...[
                  const Icon(Icons.place_outlined, size: 14, color: HomePalette.textBody),
                  const SizedBox(width: 4),
                  Flexible(child: Text(event.location!, style: const TextStyle(fontSize: 12.5, color: HomePalette.textBody))),
                ],
              ],
            ),
          ],
          if ((event.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(event.description!, style: const TextStyle(fontSize: 13.5, color: Color(0xFF4A5666), height: 1.5)),
          ],
        ],
      ),
    );
  }
}

/// Loads the readings for a given date and shows the [LiturgyScreen].
class _LiturgyByDateScreen extends ConsumerWidget {
  const _LiturgyByDateScreen({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final async = ref.watch(liturgyForDateProvider(key));

    return async.when(
      loading: () => const Scaffold(
        backgroundColor: HomePalette.screenBg,
        body: Center(child: CircularProgressIndicator(color: HomePalette.navy)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(backgroundColor: HomePalette.navy, foregroundColor: Colors.white),
        body: const Center(child: Text('Lectures indisponibles.')),
      ),
      data: (liturgy) => liturgy == null
          ? Scaffold(
              appBar: AppBar(backgroundColor: HomePalette.navy, foregroundColor: Colors.white, title: const Text('Liturgie')),
              body: const Center(child: Text('Lectures indisponibles pour ce jour.')),
            )
          : LiturgyScreen(liturgy: liturgy),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: HomePalette.textFaint),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: HomePalette.textBody)),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ],
      ),
    );
  }
}
