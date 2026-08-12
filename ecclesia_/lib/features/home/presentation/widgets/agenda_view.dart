import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/reminder_service.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../data/models/home_data.dart';
import '../providers/home_provider.dart';
import '../screens/liturgy_screen.dart';
import '../theme/home_palette.dart';
import '../theme/liturgical_colors.dart';

enum _ViewMode { calendar, list }

/// The "Agenda" tab: a real monthly calendar (Google-Agenda style) — now
/// swipeable between months — with liturgical-colour markers, category
/// filters, a chronological list alternative, this week's events, and a
/// day-detail sheet where the faithful can RSVP to parish events and set
/// reminders.
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
  static const _initialPage = 1200;
  static const _headerRowHeight = 30.0;
  static const _cellRowHeight = 42.0;

  late final DateTime _anchor;
  late final PageController _pageController;
  late DateTime _month;
  late double _gridHeight;
  _ViewMode _viewMode = _ViewMode.calendar;
  final Set<String> _activeTypes = {'liturgical', 'parish', 'mass_intention'};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _anchor = DateTime(now.year, now.month);
    _month = _anchor;
    _pageController = PageController(initialPage: _initialPage);
    _gridHeight = _heightForMonth(_month);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _key(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int _rowsForMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1;
    return ((leading + daysInMonth) / 7).ceil();
  }

  double _heightForMonth(DateTime month) => _headerRowHeight + _rowsForMonth(month) * _cellRowHeight;

  DateTime _monthForPage(int page) => DateTime(_anchor.year, _anchor.month + (page - _initialPage));

  void _goToToday() {
    HapticFeedback.selectionClick();
    _pageController.animateToPage(_initialPage, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  /// Lets the user jump straight to an arbitrary month/date (e.g. January
  /// 2030) instead of tapping the prev/next arrows repeatedly, then opens
  /// that date's event list.
  Future<void> _pickMonthDate(Map<String, List<AgendaEvent>> byDay) async {
    HapticFeedback.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Aller à une date',
    );
    if (picked == null || !mounted) return;

    final page = _initialPage + (picked.year - _anchor.year) * 12 + (picked.month - _anchor.month);
    await _pageController.animateToPage(page, duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);
    if (!mounted) return;
    _showDay(picked, byDay[_key(picked)] ?? const []);
  }

  void _toggleType(String type) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_activeTypes.contains(type)) {
        // Always keep at least one category active.
        if (_activeTypes.length > 1) _activeTypes.remove(type);
      } else {
        _activeTypes.add(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(agendaProvider);

    return async.when(
      loading: () => ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          SkeletonBox(width: double.infinity, height: 300, radius: 20),
          SizedBox(height: 22),
          SkeletonBox(width: 140, height: 15),
          SizedBox(height: 12),
          SkeletonListTile(),
          SizedBox(height: 12),
          SkeletonListTile(),
        ],
      ),
      error: (e, _) => ErrorState(message: 'Impossible de charger l\'agenda.', onRetry: () => ref.invalidate(agendaProvider)),
      data: (allEvents) {
        final events = allEvents.where((e) => _activeTypes.contains(e.type)).toList();

        final byDay = <String, List<AgendaEvent>>{};
        for (final e in events) {
          byDay.putIfAbsent(_key(e.date), () => []).add(e);
        }

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
              _modeToggle().animate().fadeIn(duration: 260.ms),
              const SizedBox(height: 14),
              if (_viewMode == _ViewMode.calendar) ...[
                _calendarCard(byDay).animate().fadeIn(duration: 320.ms).slideY(begin: .04, end: 0, duration: 320.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 16),
                _legend().animate().fadeIn(duration: 300.ms, delay: 80.ms),
                const SizedBox(height: 22),
                Text('Cette semaine', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: HomePalette.navy)),
                const SizedBox(height: 4),
                Text('${monday.day} – ${sunday.day} ${_months[sunday.month - 1].toLowerCase()}',
                    style: const TextStyle(fontSize: 12, color: HomePalette.textBody)),
                const SizedBox(height: 12),
                if (weekEvents.isEmpty)
                  const EmptyState(message: 'Aucun événement cette semaine.', icon: Icons.event_busy_outlined)
                else
                  for (final (i, e) in weekEvents.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _eventTile(e)
                          .animate()
                          .fadeIn(duration: 260.ms, delay: (i * 40).ms)
                          .slideY(begin: .05, end: 0, duration: 260.ms, delay: (i * 40).ms, curve: Curves.easeOutCubic),
                    ),
              ] else ...[
                _legend().animate().fadeIn(duration: 260.ms),
                const SizedBox(height: 16),
                ..._listSection(events),
              ],
            ],
          ),
        );
      },
    );
  }

  // ---- Mode toggle (Mois / Liste) --------------------------------------

  Widget _modeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: HomePalette.navPill, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(child: _modeButton('Mois', Icons.calendar_view_month_rounded, _ViewMode.calendar)),
          Expanded(child: _modeButton('Liste', Icons.view_list_rounded, _ViewMode.list)),
        ],
      ),
    );
  }

  Widget _modeButton(String label, IconData icon, _ViewMode mode) {
    final active = _viewMode == mode;
    return GestureDetector(
      onTap: () {
        if (_viewMode == mode) return;
        HapticFeedback.selectionClick();
        setState(() => _viewMode = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: active ? [BoxShadow(color: widget.seasonColor.withValues(alpha: .12), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: active ? widget.seasonColor : HomePalette.textMuted),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: active ? widget.seasonColor : HomePalette.textMuted)),
          ],
        ),
      ),
    );
  }

  // ---- Calendar (swipeable month grid) ----------------------------------

  Widget _calendarCard(Map<String, List<AgendaEvent>> byDay) {
    final isCurrentMonth = _month.year == _anchor.year && _month.month == _anchor.month;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HomePalette.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomePalette.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _navBtn(Icons.chevron_left, () => _pageController.previousPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut)),
              Expanded(
                child: InkWell(
                  onTap: () => _pickMonthDate(byDay),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Text(
                            '${_months[_month.month - 1]} ${_month.year}',
                            key: ValueKey('${_month.year}-${_month.month}'),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: widget.seasonColor),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.expand_more_rounded, size: 18, color: widget.seasonColor.withValues(alpha: .7)),
                      ],
                    ),
                  ),
                ),
              ),
              _navBtn(Icons.chevron_right, () => _pageController.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut)),
            ],
          ),
          if (!isCurrentMonth) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _goToToday,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: widget.seasonColor.withValues(alpha: .1), borderRadius: BorderRadius.circular(100)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.today_rounded, size: 13, color: widget.seasonColor),
                    const SizedBox(width: 5),
                    Text("Aujourd'hui", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: widget.seasonColor)),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 180.ms),
          ],
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            height: _gridHeight - _headerRowHeight,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                final month = _monthForPage(page);
                setState(() {
                  _month = month;
                  _gridHeight = _heightForMonth(month);
                });
              },
              itemBuilder: (context, page) => _monthGrid(_monthForPage(page), byDay),
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthGrid(DateTime month, Map<String, List<AgendaEvent>> byDay) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1;
    final rows = _rowsForMonth(month);
    final today = DateTime.now();

    return Column(
      children: [
        for (var r = 0; r < rows; r++)
          Expanded(
            child: Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(
                    child: Builder(builder: (context) {
                      final dayNum = r * 7 + c - leading + 1;
                      if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox.shrink();

                      final date = DateTime(month.year, month.month, dayNum);
                      final dayEvents = byDay[_key(date)] ?? const [];
                      final isToday = date.year == today.year && date.month == today.month && date.day == today.day;

                      return _DayCell(
                        day: dayNum,
                        isToday: isToday,
                        seasonColor: widget.seasonColor,
                        dots: dayEvents
                            .take(3)
                            .map((e) => LiturgicalColors.dot(isParish: e.isParish, liturgicalColor: e.color, isMassIntention: e.isMassIntention))
                            .toList(),
                        overflow: dayEvents.length > 3 ? dayEvents.length - 3 : 0,
                        onTap: dayEvents.isEmpty ? null : () => _showDay(date, dayEvents),
                      );
                    }),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 22, color: HomePalette.textAuthor)),
      );

  // ---- Legend / category filters -----------------------------------------

  Widget _legend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _filterPill('Fêtes liturgiques', LiturgicalColors.white, 'liturgical'),
            _filterPill('Événements paroisse', LiturgicalColors.parish, 'parish'),
            _filterPill('Mes intentions', LiturgicalColors.massIntention, 'mass_intention'),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            (LiturgicalColors.white, 'Solennités & saints'),
            (LiturgicalColors.red, 'Martyrs · Pentecôte'),
            (LiturgicalColors.purple, 'Avent · Carême'),
            (LiturgicalColors.green, 'Temps ordinaire'),
          ]
              .map((e) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 9, height: 9, decoration: BoxDecoration(color: e.$1, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text(e.$2, style: const TextStyle(fontSize: 11, color: HomePalette.textBody)),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _filterPill(String label, Color color, String type) {
    final active = _activeTypes.contains(type);
    return GestureDetector(
      onTap: () => _toggleType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: .12) : HomePalette.screenBg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: active ? color.withValues(alpha: .5) : HomePalette.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: active ? color : HomePalette.textFaint, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: active ? HomePalette.navy : HomePalette.textMuted)),
          ],
        ),
      ),
    );
  }

  // ---- List view ----------------------------------------------------------

  List<Widget> _listSection(List<AgendaEvent> events) {
    if (events.isEmpty) {
      return const [EmptyState(message: 'Aucun événement à venir.', icon: Icons.event_busy_outlined)];
    }

    final sorted = [...events]..sort((a, b) => a.date.compareTo(b.date));
    final widgets = <Widget>[];
    String? lastMonthKey;
    var i = 0;

    for (final e in sorted) {
      final monthKey = '${e.date.year}-${e.date.month}';
      if (monthKey != lastMonthKey) {
        lastMonthKey = monthKey;
        widgets.add(Padding(
          padding: EdgeInsets.only(top: widgets.isEmpty ? 0 : 18, bottom: 10),
          child: Text('${_months[e.date.month - 1]} ${e.date.year}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: HomePalette.navy)),
        ));
      }
      final delay = (i.clamp(0, 10) * 40).ms;
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _eventTile(e).animate().fadeIn(duration: 240.ms, delay: delay).slideY(begin: .04, end: 0, duration: 240.ms, delay: delay, curve: Curves.easeOutCubic),
      ));
      i++;
    }
    return widgets;
  }

  // ---- Shared event tile (week list + list view) --------------------------

  Widget _eventTile(AgendaEvent e) {
    final color = LiturgicalColors.dot(isParish: e.isParish, liturgicalColor: e.color, isMassIntention: e.isMassIntention);
    return InkWell(
      onTap: () => _showDay(e.date, [e]),
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
            if (e.isParish && (e.attendeesCount ?? 0) > 0) ...[
              Icon(Icons.people_alt_rounded, size: 13, color: HomePalette.textFaint),
              const SizedBox(width: 3),
              Text('${e.attendeesCount}', style: const TextStyle(fontSize: 11.5, color: HomePalette.textFaint)),
              const SizedBox(width: 8),
            ],
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }

  void _showDay(DateTime date, List<AgendaEvent> events) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _DayDetailSheet(date: date, events: events, seasonColor: widget.seasonColor),
    );
  }

  static const _daysLong = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  String _weekdayLong(DateTime d) => _daysLong[d.weekday - 1];
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.isToday, required this.dots, required this.seasonColor, this.overflow = 0, this.onTap});

  final int day;
  final bool isToday;
  final List<Color> dots;
  final Color seasonColor;
  final int overflow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasEvents = dots.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: hasEvents && !isToday ? (dots.first).withValues(alpha: .07) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
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
            const SizedBox(height: 2),
            SizedBox(
              height: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...dots.map((c) => Container(
                        width: 5, height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                      )),
                  if (overflow > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: Text('+$overflow', style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: HomePalette.textMuted)),
                    ),
                ],
              ),
            ),
          ],
        ),
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
                  children: [for (final e in events) _EventDetail(event: e)],
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

class _EventDetail extends ConsumerStatefulWidget {
  const _EventDetail({required this.event});

  final AgendaEvent event;

  @override
  ConsumerState<_EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends ConsumerState<_EventDetail> {
  late bool _attending = widget.event.isAttending ?? false;
  late int _attendeesCount = widget.event.attendeesCount ?? 0;
  bool _rsvpBusy = false;

  bool? _reminderSet;
  bool _reminderBusy = false;

  int get _reminderId => ReminderService.idFor(
        type: widget.event.type,
        eventId: widget.event.id,
        date: widget.event.date,
        title: widget.event.title,
      );

  DateTime get _reminderMoment {
    final e = widget.event;
    if (e.time != null) {
      final parts = e.time!.split(':');
      final h = int.tryParse(parts[0]) ?? 8;
      final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      return DateTime(e.date.year, e.date.month, e.date.day, h, m).subtract(const Duration(hours: 1));
    }
    return DateTime(e.date.year, e.date.month, e.date.day, 8);
  }

  @override
  void initState() {
    super.initState();
    ReminderService.instance.isScheduled(_reminderId).then((v) {
      if (mounted) setState(() => _reminderSet = v);
    });
  }

  Future<void> _toggleRsvp() async {
    final id = widget.event.id;
    if (id == null || _rsvpBusy) return;
    setState(() {
      _rsvpBusy = true;
      _attending = !_attending;
      _attendeesCount += _attending ? 1 : -1;
    });
    HapticFeedback.selectionClick();
    try {
      final result = await ref.read(homeRemoteDataSourceProvider).toggleEventRsvp(id);
      if (!mounted) return;
      setState(() {
        _attending = result.isAttending;
        _attendeesCount = result.attendeesCount;
      });
      ref.invalidate(agendaProvider);
    } catch (_) {
      if (!mounted) return;
      // Revert the optimistic update on failure.
      setState(() {
        _attending = !_attending;
        _attendeesCount += _attending ? 1 : -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'enregistrer votre participation."), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _rsvpBusy = false);
    }
  }

  Future<void> _toggleReminder() async {
    if (_reminderBusy || _reminderSet == null) return;
    setState(() => _reminderBusy = true);
    HapticFeedback.selectionClick();

    if (_reminderSet!) {
      await ReminderService.instance.cancel(_reminderId);
      if (mounted) {
        setState(() {
          _reminderSet = false;
          _reminderBusy = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rappel annulé.'), behavior: SnackBarBehavior.floating));
      }
      return;
    }

    final granted = await ReminderService.instance.requestPermission();
    if (!granted) {
      if (mounted) {
        setState(() => _reminderBusy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autorisez les notifications pour recevoir un rappel.'), behavior: SnackBarBehavior.floating),
        );
      }
      return;
    }

    final scheduled = await ReminderService.instance.schedule(
      id: _reminderId,
      title: widget.event.title,
      body: widget.event.time != null ? 'Dans 1 heure · ${widget.event.time}' : "Aujourd'hui",
      at: _reminderMoment,
    );

    if (!mounted) return;
    setState(() {
      _reminderSet = scheduled;
      _reminderBusy = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(scheduled ? 'Rappel activé.' : "Cet événement est trop proche pour un rappel."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final color = LiturgicalColors.dot(isParish: event.isParish, liturgicalColor: event.color, isMassIntention: event.isMassIntention);
    final canRemind = _reminderMoment.isAfter(DateTime.now());

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
              Icon(
                event.isMassIntention ? Icons.church_outlined : (event.isParish ? Icons.groups_outlined : Icons.auto_awesome_outlined),
                size: 15,
                color: color,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  event.isMassIntention
                      ? (event.confirmed == true ? 'Intention confirmée' : 'Intention en attente de paiement')
                      : (event.isParish ? 'Événement paroisse' : (event.subtitle ?? 'Fête')),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                ),
              ),
              if (canRemind)
                GestureDetector(
                  onTap: _toggleReminder,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: _reminderBusy
                        ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: color))
                        : Icon(
                            _reminderSet == true ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                            size: 18,
                            color: _reminderSet == true ? HomePalette.gold : HomePalette.textMuted,
                          ),
                  ),
                ),
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
          if (event.isParish && event.id != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: _toggleRsvp,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(
                      color: _attending ? color : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: color),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_attending ? Icons.check_circle : Icons.add_circle_outline, size: 15, color: _attending ? Colors.white : color),
                        const SizedBox(width: 6),
                        Text(
                          _attending ? "J'y serai" : "Je participe",
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _attending ? Colors.white : color),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (_attendeesCount > 0)
                  Text('$_attendeesCount participant${_attendeesCount > 1 ? 's' : ''}', style: const TextStyle(fontSize: 11.5, color: HomePalette.textMuted)),
              ],
            ),
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
      loading: () => Scaffold(
        backgroundColor: HomePalette.screenBg,
        appBar: AppBar(backgroundColor: HomePalette.navy, foregroundColor: Colors.white),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: SkeletonParagraph(lines: 6),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: HomePalette.screenBg,
        appBar: AppBar(backgroundColor: HomePalette.navy, foregroundColor: Colors.white),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: ErrorState(message: 'Lectures indisponibles.'),
        ),
      ),
      data: (liturgy) => liturgy == null
          ? Scaffold(
              backgroundColor: HomePalette.screenBg,
              appBar: AppBar(backgroundColor: HomePalette.navy, foregroundColor: Colors.white, title: const Text('Liturgie')),
              body: const Padding(
                padding: EdgeInsets.all(20),
                child: EmptyState(message: 'Lectures indisponibles pour ce jour.', icon: Icons.menu_book_outlined),
              ),
            )
          : LiturgyScreen(liturgy: liturgy),
    );
  }
}
