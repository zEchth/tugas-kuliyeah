import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Makassar'));
    

    debugPrint("TZ ACTIVE: ${tz.local.name}");
    debugPrint("NOW TZ: ${tz.TZDateTime.now(tz.local)}");

    // Icon notifikasi untuk Android (Pastikan file g-logo.png atau ic_launcher ada di res/drawable)
    // Biasanya menggunakan @mipmap/ic_launcher default flutter
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    ); // '@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("NOTIF CLICKED: ${details.payload}");
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // CREATE CHANNELS
    const tugasChannel = AndroidNotificationChannel(
      'channel_tugas_id',
      'Reminder Tugas',
      description: 'Notifikasi tenggat tugas',
      importance: Importance.max,
    );

    const jadwalChannel = AndroidNotificationChannel(
      'channel_jadwal_id',
      'Jadwal Kuliah',
      description: 'Notifikasi jadwal kuliah',
      importance: Importance.max,
    );

    final androidImpl = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImpl?.createNotificationChannel(tugasChannel);
    await androidImpl?.createNotificationChannel(jadwalChannel);

    // FIX: request exact alarm permission (Android 13+)
    if (Platform.isAndroid) {
      await _requestExactAlarmPermission();
    }
  }

  // === Minta exact alarm permission (Android 13+) ===
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

    // Jangan jadwalkan jika waktu sudah lewat
    if (scheduledDate.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.cancel(id);

    final canExact = await _canUseExactAlarm();

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_tugas_id',
            'Reminder Tugas',
            channelDescription: 'Notifikasi tenggat tugas',
            importance: Importance.max,
            priority: Priority.high,
            // Menambahkan suara/getar default
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: canExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint("Scheduled Notification ID: $id at $scheduledDate");
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  // === REMINDER JADWAL KULIAH ===
  // Future<void> scheduleJadwalKuliah({
  //   required int id,
  //   required String title,
  //   required String body,
  //   required int dayOfWeek, // 1 = Senin, 7 = Minggu
  //   required int hour,
  //   required int minute,
  // }) async {
  //   if (kIsWeb) return;
  //   final canExact = await _canUseExactAlarm();

  //   try {
  //     await flutterLocalNotificationsPlugin.zonedSchedule(
  //       id,
  //       title,
  //       body,
  //       _nextInstanceOfDay(dayOfWeek, hour, minute),
  //       const NotificationDetails(
  //         android: AndroidNotificationDetails(
  //           'channel_jadwal_id',
  //           'Jadwal Kuliah',
  //           channelDescription: 'Notifikasi jadwal kuliah mingguan',
  //           importance: Importance.max,
  //           priority: Priority.high,
  //         ),
  //       ),
  //       androidScheduleMode: canExact
  //           ? AndroidScheduleMode.exactAllowWhileIdle
  //           : AndroidScheduleMode.inexact,
  //       uiLocalNotificationDateInterpretation:
  //           UILocalNotificationDateInterpretation.absoluteTime,
  //       matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
  //     );
  //   } catch (e) {
  //     debugPrint("Error scheduling jadwal: $e");
  //   }
  // }

  // tz.TZDateTime _nextInstanceOfDay(int dow, int h, int m) {
  //   final now = tz.TZDateTime.now(tz.local);
  //   var result = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);

  //   // Loop sampai ketemu hari yang sesuai
  //   while (result.weekday != dow) {
  //     result = result.add(const Duration(days: 1));
  //   }

  //   // Jika waktu sudah lewat hari ini, tambahkan 1 minggu
  //   if (result.isBefore(now)) {
  //     result = result.add(const Duration(days: 7));
  //   }
  //   return result;
  // }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // [BARU] Hapus semua notifikasi (Untuk Logout & Resync)
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint("All notifications cancelled.");
  }
}
