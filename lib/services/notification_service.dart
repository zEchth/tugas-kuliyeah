import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(android: android, iOS: ios);

    await flutterLocalNotificationsPlugin.initialize(settings);

    // FIX: request exact alarm permission (Android 13+)
    if (Platform.isAndroid) {
      await _requestExactAlarmPermission();
    }
  }

  // === FIX: Minta exact alarm permission (Android 13+) ===
  Future<void> _requestExactAlarmPermission() async {
    if (kIsWeb) return;

    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  // === CEK APAKAH EXACT ALARM DIIZINKAN ===
  Future<bool> _canUseExactAlarm() async {
    if (kIsWeb) return false;

    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation == null) return false;

    return await androidImplementation.canScheduleExactNotifications() ?? false;
  }

  // === REMINDER TUGAS ===
  Future<void> scheduleTugasReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb) return;
    if (scheduledDate.isBefore(DateTime.now())) return;

    final canExact = await _canUseExactAlarm();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_tugas_id',
          'Reminder Tugas',
          channelDescription: 'Notifikasi tenggat tugas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // === REMINDER JADWAL KULIAH ===
  Future<void> scheduleJadwalKuliah({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return;
    final canExact = await _canUseExactAlarm();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfDay(dayOfWeek, hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_jadwal_id',
          'Jadwal Kuliah',
          channelDescription: 'Notifikasi jadwal kuliah mingguan',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfDay(int dow, int h, int m) {
    final now = tz.TZDateTime.now(tz.local);
    var result = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);

    while (result.weekday != dow) {
      result = result.add(const Duration(days: 1));
    }

    if (result.isBefore(now)) {
      result = result.add(const Duration(days: 7));
    }
    return result;
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // === TEST NOTIF LANGSUNG (TIDAK PAKAI ALARM) ===
  // Future<void> testImmediateNotif() async {
  //   await flutterLocalNotificationsPlugin.show(
  //     9999,
  //     "Test Notifikasi",
  //     "Kalau ini muncul berarti notif kamu hidup",
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'test_channel',
  //         'Test Channel',
  //         channelDescription: 'Channel untuk testing notifikasi',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //       iOS: DarwinNotificationDetails(),
  //     ),
  //   );
  // }
}
