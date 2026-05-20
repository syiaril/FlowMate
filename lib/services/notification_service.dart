import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timezoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('[NotificationService] Timezone set successfully to: $timeZoneName');
    } catch (e) {
      debugPrint('[NotificationService] Failed to set local timezone, defaulting to UTC: $e');
    }

    // Android settings
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

    // Request permissions on Android 13+
    await requestPermission();

    _initialized = true;
    debugPrint('[NotificationService] Initialized successfully.');

    // Proactively schedule reminders
    try {
      await scheduleDailyMoodReminder();
      await scheduleMonthlyReminder();
    } catch (e) {
      debugPrint('[NotificationService] Error scheduling default reminders: $e');
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
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      debugPrint('[NotificationService] Android permission request result: $granted');
      return granted ?? false;
    }
    return true;
  }

  // ──────────────────────────────────────────────
  // Android notification details (shared)
  // ──────────────────────────────────────────────

  AndroidNotificationDetails get _androidDetails =>
      const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/launcher_icon',
      );

  NotificationDetails get _notificationDetails => NotificationDetails(
    android: _androidDetails,
    iOS: const DarwinNotificationDetails(),
  );

  // ──────────────────────────────────────────────

  Future<void> showNotification({required int id, required String title, required String body}) async {
    await _plugin.show(
      id,
      title,
      body,
      _notificationDetails,
    );
  }

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
    // Schedule today at 20:00. If it's already past 20:00, zonedSchedule will automatically schedule it for tomorrow.
    var scheduledDate = DateTime(now.year, now.month, now.day, 20, 0);
    if (now.hour >= 20) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      _dailyMoodReminderId,
      'Bagaimana Mood Kamu Hari Ini? 🌟',
      'Jangan lupa untuk meluangkan waktu sejenak mencatat mood dan gejalamu hari ini ya!',
      scheduledTZDate,
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_mood_reminder',
    );

    debugPrint(
      '[NotificationService] Daily mood reminder scheduled for $scheduledTZDate (repeats daily)',
    );
  }

  /// Schedule a one-time test notification in 5 seconds for testing.
  Future<void> scheduleTestNotification() async {
    if (!_initialized) await init();

    final scheduledDate = DateTime.now().add(const Duration(seconds: 5));
    final scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      999, // Test notification ID
      'Tes Pengingat Mood 🌟',
      'Ini adalah simulasi pengingat harian: Bagaimana mood kamu hari ini?',
      scheduledTZDate,
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'test_reminder',
    );
    
    debugPrint(
      '[NotificationService] Test notification scheduled in 5 seconds at $scheduledTZDate',
    );
  }
}
