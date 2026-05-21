import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service responsible for scheduling and managing local notifications.
///
/// Uses flutter_local_notifications for period reminders and
/// monthly logging reminders.
class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  /// Access the singleton instance
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Whether the service has been initialized
  bool _initialized = false;

  // ──────────────────────────────────────────────
  // Channel configuration
  // ──────────────────────────────────────────────
  static const String _channelId = 'flowmate_channel';
  static const String _channelName = 'FlowMate Reminders';
  static const String _channelDescription =
      'Pengingat siklus menstruasi dan pencatatan';

  // Notification IDs
  static const int _periodReminderId = 100;
  static const int _monthlyReminderId = 200;
  static const int _dailyMoodReminderId = 300;

  // ──────────────────────────────────────────────
  // Initialization
  // ──────────────────────────────────────────────

  /// Initialize the notification plugin with platform-specific settings.
  /// Must be called once (typically in main() after runApp or before).
  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    // Try to detect local timezone dynamically.
    // flutter_timezone returns a TimezoneInfo object; we need .identifier.
    try {
      // Use platform default timezone name from Dart
      final timeZoneName = DateTime.now().timeZoneName;
      // Try mapping common abbreviations to IANA names
      final ianaName = _resolveTimezone(timeZoneName);
      tz.setLocalLocation(tz.getLocation(ianaName));
      debugPrint(
          '[NotificationService] Timezone set to: $ianaName (from: $timeZoneName)');
    } catch (e) {
      // Fallback: try to detect from UTC offset
      try {
        final offset = DateTime.now().timeZoneOffset;
        final ianaName = _timezoneFromOffset(offset);
        tz.setLocalLocation(tz.getLocation(ianaName));
        debugPrint(
            '[NotificationService] Timezone set from offset: $ianaName');
      } catch (e2) {
        debugPrint(
            '[NotificationService] Failed to set timezone, using UTC: $e2');
      }
    }

    // Android settings — use default app icon
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    // iOS / macOS settings
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('[NotificationService] Plugin initialized.');

    // Request permissions on Android 13+
    final permGranted = await requestPermission();
    debugPrint('[NotificationService] Permission granted: $permGranted');

    // Request exact alarm permission on Android 12+
    await _requestExactAlarmPermission();

    // Proactively schedule reminders
    try {
      await scheduleDailyMoodReminder();
      await scheduleMonthlyReminder();
      debugPrint('[NotificationService] Default reminders scheduled.');
    } catch (e) {
      debugPrint(
          '[NotificationService] Error scheduling default reminders: $e');
    }
  }

  /// Resolve timezone abbreviation to IANA name.
  String _resolveTimezone(String tzName) {
    // Common Indonesian / Asian timezone abbreviations
    const Map<String, String> abbreviations = {
      'WIB': 'Asia/Jakarta',
      'WITA': 'Asia/Makassar',
      'WIT': 'Asia/Jayapura',
      'SGT': 'Asia/Singapore',
      'ICT': 'Asia/Bangkok',
      'JST': 'Asia/Tokyo',
      'KST': 'Asia/Seoul',
      'CST': 'Asia/Shanghai',
      'IST': 'Asia/Kolkata',
      'GMT': 'GMT',
      'UTC': 'UTC',
      'EST': 'America/New_York',
      'PST': 'America/Los_Angeles',
      'CET': 'Europe/Paris',
    };

    if (abbreviations.containsKey(tzName)) {
      return abbreviations[tzName]!;
    }

    // Try using it directly (it might already be an IANA name)
    try {
      tz.getLocation(tzName);
      return tzName;
    } catch (_) {
      // Fallback to offset-based detection
      return _timezoneFromOffset(DateTime.now().timeZoneOffset);
    }
  }

  /// Determine IANA timezone name from UTC offset.
  String _timezoneFromOffset(Duration offset) {
    final hours = offset.inHours;
    switch (hours) {
      case 7:
        return 'Asia/Jakarta'; // WIB
      case 8:
        return 'Asia/Makassar'; // WITA
      case 9:
        return 'Asia/Jayapura'; // WIT
      case 5:
        return 'Asia/Kolkata';
      case 0:
        return 'UTC';
      case -5:
        return 'America/New_York';
      case -8:
        return 'America/Los_Angeles';
      case 1:
        return 'Europe/Paris';
      default:
        return 'UTC';
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint(
      '[NotificationService] Notification tapped: ${response.payload}',
    );
    // Navigation can be handled here if needed
  }

  /// Request notification permissions on Android 13+ (API 33+).
  Future<bool> requestPermission() async {
    try {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint(
            '[NotificationService] Android notification permission: $granted');
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('[NotificationService] Error requesting permission: $e');
    }
    return true;
  }

  /// Request exact alarm permission on Android 12+ (API 31+).
  Future<void> _requestExactAlarmPermission() async {
    try {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        await androidPlugin.requestExactAlarmsPermission();
        debugPrint(
            '[NotificationService] Exact alarm permission requested.');
      }
    } catch (e) {
      debugPrint(
          '[NotificationService] Error requesting exact alarm permission: $e');
    }
  }

  // ──────────────────────────────────────────────
  // Android notification details (shared)
  // ──────────────────────────────────────────────

  AndroidNotificationDetails get _androidDetails =>
      const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/launcher_icon',
      );

  NotificationDetails get _notificationDetails => NotificationDetails(
    android: _androidDetails,
    iOS: const DarwinNotificationDetails(),
  );

  // ──────────────────────────────────────────────

  /// Show an immediate notification (no scheduling).
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();
    await _plugin.show(
      id,
      title,
      body,
      _notificationDetails,
    );
    debugPrint('[NotificationService] Showed immediate notification: $title');
  }

  // ──────────────────────────────────────────────
  // Schedule: Period reminder
  // ──────────────────────────────────────────────

  /// Schedule a notification 1 day before the predicted [nextPeriod] date.
  ///
  /// If [nextPeriod] is in the past, the notification is not scheduled.
  Future<void> schedulePeriodReminder(DateTime nextPeriod) async {
    if (!_initialized) await init();

    // Remind 1 day before
    final reminderDate = nextPeriod.subtract(const Duration(days: 1));
    final now = DateTime.now();

    if (reminderDate.isBefore(now)) {
      debugPrint(
        '[NotificationService] Skipping period reminder — date is in the past.',
      );
      return;
    }

    final scheduledDate = tz.TZDateTime.from(reminderDate, tz.local);

    try {
      await _plugin.zonedSchedule(
        _periodReminderId,
        'Pengingat Menstruasi 🩸',
        'Perkiraan menstruasi kamu dimulai besok. Siapkan dirimu!',
        scheduledDate,
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'period_reminder',
      );
      debugPrint(
        '[NotificationService] Period reminder scheduled for $scheduledDate',
      );
    } catch (e) {
      debugPrint('[NotificationService] Error scheduling period reminder: $e');
    }
  }

  // ──────────────────────────────────────────────
  // Schedule: Monthly logging reminder
  // ──────────────────────────────────────────────

  /// Schedule a monthly reminder to log mood and symptoms.
  /// Fires on the 1st of every month at 09:00.
  Future<void> scheduleMonthlyReminder() async {
    if (!_initialized) await init();

    // Calculate next 1st of month at 09:00
    final now = DateTime.now();
    var nextFirst = DateTime(now.year, now.month + 1, 1, 9, 0);
    if (now.day == 1 && now.hour < 9) {
      nextFirst = DateTime(now.year, now.month, 1, 9, 0);
    }

    final scheduledDate = tz.TZDateTime.from(nextFirst, tz.local);

    try {
      await _plugin.zonedSchedule(
        _monthlyReminderId,
        'Catat Siklus Bulananmu 📝',
        'Jangan lupa catat mood dan gejala kamu bulan ini!',
        scheduledDate,
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'monthly_reminder',
      );
      debugPrint(
        '[NotificationService] Monthly reminder scheduled for $scheduledDate',
      );
    } catch (e) {
      debugPrint(
          '[NotificationService] Error scheduling monthly reminder: $e');
    }
  }

  // ──────────────────────────────────────────────
  // Cancel
  // ──────────────────────────────────────────────

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('[NotificationService] All notifications cancelled.');
  }

  /// Cancel only the period reminder.
  Future<void> cancelPeriodReminder() async {
    await _plugin.cancel(_periodReminderId);
  }

  /// Cancel only the monthly reminder.
  Future<void> cancelMonthlyReminder() async {
    await _plugin.cancel(_monthlyReminderId);
  }

  /// Cancel only the daily mood reminder.
  Future<void> cancelDailyMoodReminder() async {
    await _plugin.cancel(_dailyMoodReminderId);
  }

  // ──────────────────────────────────────────────
  // Schedule: Daily mood logging reminder
  // ──────────────────────────────────────────────

  /// Schedule a daily reminder to log mood at 20:00 (8:00 PM).
  Future<void> scheduleDailyMoodReminder() async {
    if (!_initialized) await init();

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 20, 0);
    if (now.hour >= 20) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);

    try {
      await _plugin.zonedSchedule(
        _dailyMoodReminderId,
        'Bagaimana Mood Kamu Hari Ini? 🌟',
        'Jangan lupa untuk meluangkan waktu sejenak mencatat mood dan gejalamu hari ini ya!',
        scheduledTZDate,
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_mood_reminder',
      );
      debugPrint(
        '[NotificationService] Daily mood reminder scheduled for $scheduledTZDate (repeats daily)',
      );
    } catch (e) {
      debugPrint(
          '[NotificationService] Error scheduling daily mood reminder: $e');
    }
  }

  /// Show an immediate test notification (no scheduling delay).
  /// This is the most reliable way to test if notifications work.
  Future<void> showTestNotification() async {
    if (!_initialized) await init();

    await _plugin.show(
      999,
      'Tes Notifikasi FlowMate ✅',
      'Notifikasi berhasil! Pengingat mood harian akan aktif setiap jam 8 malam.',
      _notificationDetails,
      payload: 'test_notification',
    );

    debugPrint('[NotificationService] Immediate test notification shown.');
  }

  /// Get list of pending (scheduled) notifications for debugging.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }
}
