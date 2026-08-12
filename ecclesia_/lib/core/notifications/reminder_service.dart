import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Local, on-device reminders for agenda events — separate from the
/// server-driven notification center (that one is "what happened", this one
/// is "don't forget what's coming"). No backend involved: each reminder is
/// scheduled directly with the OS and identified by a stable id derived from
/// the event, so [isScheduled] can be answered by simply asking the OS
/// what's pending — no local database to keep in sync.
class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'event_reminders';

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    // The parish app targets Côte d'Ivoire (UTC+0, no DST) — a fixed
    // location keeps scheduling correct without a device-timezone plugin.
    tz.setLocalLocation(tz.getLocation('Africa/Abidjan'));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    _initialized = true;
  }

  /// Asks for OS-level notification permission (Android 13+ / iOS). Safe to
  /// call repeatedly — the OS only prompts once.
  Future<bool> requestPermission() async {
    await _ensureInitialized();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return granted ?? true;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? true;
    }
    return true;
  }

  /// A stable notification id for an agenda item, so scheduling the same
  /// event twice replaces rather than duplicates the reminder.
  static int idFor({required String type, required int? eventId, required DateTime date, required String title}) {
    final key = eventId != null ? '$type-$eventId' : '$type-${date.toIso8601String()}-$title';
    return key.hashCode & 0x7fffffff;
  }

  Future<bool> isScheduled(int id) async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.any((n) => n.id == id);
  }

  /// Schedules a one-off reminder at [at]. Returns false without scheduling
  /// if [at] is already past.
  Future<bool> schedule({required int id, required String title, required String body, required DateTime at}) async {
    await _ensureInitialized();
    if (at.isBefore(DateTime.now())) return false;

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          "Rappels d'événements",
          channelDescription: 'Rappels avant vos messes, réunions et événements paroissiaux',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    return true;
  }

  Future<void> cancel(int id) async {
    await _ensureInitialized();
    await _plugin.cancel(id: id);
  }
}
