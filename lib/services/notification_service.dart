// lib/services/notification_service.dart
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
    
    // [UPDATE] Hapus Hardcode Makassar. Biarkan mengikuti Local Device Time.
    // tz.setLocalLocation(tz.getLocation('Asia/Makassar'));

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

  // [BARU] Helper untuk mendapatkan Lokasi TZ berdasarkan String WIB/WITA/WIT
  tz.Location _getLocation(String zonaWaktu) {
    try {
      switch (zonaWaktu.toUpperCase()) {
        case 'WIB':
          return tz.getLocation('Asia/Jakarta');
        case 'WIT':
          return tz.getLocation('Asia/Jayapura');
        case 'WITA':
        default:
          return tz.getLocation('Asia/Makassar');
      }
    } catch (e) {
      // Fallback jika database timezones belum diload sempurna atau nama salah
      debugPrint("Error getting location for $zonaWaktu: $e");
      return tz.local;
    }
  }

  // === REMINDER TUGAS & JADWAL (Unified) ===
  // [UPDATE] Menambahkan parameter zonaWaktu
  Future<void> scheduleTugasReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String zonaWaktu = 'WITA', // Default backward compatibility
  }) async {
    if (kIsWeb) return;

    // 2 jam sebelum deadline (Opsional, dinonaktifkan sementara agar sesuai request jam pas)
    // final notifTime = scheduledDate.subtract(const Duration(hours: 2));

    await flutterLocalNotificationsPlugin.cancel(id);

    final canExact = await _canUseExactAlarm();
    final targetLocation = _getLocation(zonaWaktu);

    // [LOGIKA PENTING] Konversi DateTime UI (Local Year/Month/Hour) ke Zona Target
    // Kita gunakan constructor TZDateTime(location, ...) agar komponen waktu (Jam 7)
    // tetap Jam 7 di zona tersebut, lalu library akan menghitung offset ke device time.
    final tzScheduledDate = tz.TZDateTime(
      targetLocation,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledDate.hour,
      scheduledDate.minute,
    );

    // Cek apakah waktu sudah lewat (dalam absolute time)
    final nowInTarget = tz.TZDateTime.now(targetLocation);
    if (tzScheduledDate.isBefore(nowInTarget)) {
      // debugPrint("Waktu sudah lewat untuk notif ID $id. Skip.");
      return; 
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate, // Gunakan waktu yang sudah di-zone
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
      debugPrint("Scheduled Notif ID: $id at $tzScheduledDate ($zonaWaktu)");
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  // [DEPRECATED / REMOVED] scheduleJadwalKuliah (Weekly Recurring)
  // Kita ganti strategi: Jadwal kuliah sekarang dijadwalkan sebagai One-Time Alarm
  // untuk setiap pertemuan (generated batch) agar support tanggal merah & libur lebih mudah.
  // Logic penjadwalannya ada di Repository (looping setiap tanggal pertemuan).

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

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_tugas_id',
        'Reminder Tugas',
        channelDescription: 'Notifikasi langsung dari FCM',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID unik
      title,
      body,
      notificationDetails,
    );
  }
}