import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // ⚠️ GANTI INI DENGAN VAPID KEY DARI FIREBASE CONSOLE (LANGKAH 1)
  final String _vapidKey = "BPNhDyKG8TXscD_YqMxfhhfS7oAaGVAI47_Bejvu6_PiiPxBWUeEboyE1U0JA2T_qurQtmRl1niBtlX5v9HY-eM";

  /// Inisialisasi Service
  Future<void> init() async {
    // 1. Minta Izin Notifikasi
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Izin notifikasi diberikan');
      
      // 2. Jika user sudah login, langsung simpan token
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await uploadFcmToken(user.id);
      }
      
      // 3. Listen token refresh (jika token berubah)
      _fcm.onTokenRefresh.listen((newToken) {
        if (_supabase.auth.currentUser != null) {
          _saveTokenToDb(newToken, _supabase.auth.currentUser!.id);
        }
      });
      
    } else {
      debugPrint('Izin notifikasi ditolak');
    }

    // 4. Handle Notifikasi saat aplikasi dibuka (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Pesan diterima saat foreground: ${message.notification?.title}');
      // Di sini Anda bisa memunculkan SnackBar atau Dialog custom
    });
  }

  /// Mendapatkan FCM Token dan menyimpannya ke Supabase
  Future<void> uploadFcmToken(String userId) async {
    try {
      String? token;
      
      if (kIsWeb) {
        token = await _fcm.getToken(vapidKey: _vapidKey);
      } else {
        token = await _fcm.getToken();
      }

      if (token != null) {
        debugPrint("FCM Token: $token");
        await _saveTokenToDb(token, userId);
      }
    } catch (e) {
      debugPrint("Gagal mengambil/menyimpan token: $e");
    }
  }

  /// Logika simpan ke tabel fcm_tokens
  Future<void> _saveTokenToDb(String token, String userId) async {
    try {
      // Upsert: Masukkan jika belum ada, abaikan jika duplikat
      await _supabase.from('fcm_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'created_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'token', // Token harus unik di tabel
      ); 
      debugPrint("Token berhasil disimpan ke DB");
    } catch (e) {
      // Abaikan error duplikat atau error koneksi ringan
      debugPrint("Info simpan token: $e"); 
    }
  }
}

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
// import 'dart:io';
// import 'dart:io' show Platform;
// import 'package:flutter/foundation.dart';

// class NotificationService {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> init() async {
//     if (kIsWeb) return;

//     tz.initializeTimeZones();

//     const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const ios = DarwinInitializationSettings();

//     const settings = InitializationSettings(android: android, iOS: ios);

//     await flutterLocalNotificationsPlugin.initialize(settings);

//     // FIX: request exact alarm permission (Android 13+)
//     if (Platform.isAndroid) {
//       await _requestExactAlarmPermission();
//     }
//   }

//   // === FIX: Minta exact alarm permission (Android 13+) ===
//   Future<void> _requestExactAlarmPermission() async {
//     if (kIsWeb) return;

//     final androidImplementation = flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >();

//     if (androidImplementation != null) {
//       await androidImplementation.requestExactAlarmsPermission();
//     }
//   }

//   // === CEK APAKAH EXACT ALARM DIIZINKAN ===
//   Future<bool> _canUseExactAlarm() async {
//     if (kIsWeb) return false;

//     final androidImplementation = flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >();

//     if (androidImplementation == null) return false;

//     return await androidImplementation.canScheduleExactNotifications() ?? false;
//   }

//   // === REMINDER TUGAS ===
//   Future<void> scheduleTugasReminder({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//   }) async {
//     if (kIsWeb) return;
//     if (scheduledDate.isBefore(DateTime.now())) return;

//     final canExact = await _canUseExactAlarm();

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.from(scheduledDate, tz.local),
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           'channel_tugas_id',
//           'Reminder Tugas',
//           channelDescription: 'Notifikasi tenggat tugas',
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//       ),
//       androidScheduleMode: canExact
//           ? AndroidScheduleMode.exactAllowWhileIdle
//           : AndroidScheduleMode.inexact,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }

//   // === REMINDER JADWAL KULIAH ===
//   Future<void> scheduleJadwalKuliah({
//     required int id,
//     required String title,
//     required String body,
//     required int dayOfWeek,
//     required int hour,
//     required int minute,
//   }) async {
//     if (kIsWeb) return;
//     final canExact = await _canUseExactAlarm();

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       _nextInstanceOfDay(dayOfWeek, hour, minute),
//       NotificationDetails(
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
//   }

//   tz.TZDateTime _nextInstanceOfDay(int dow, int h, int m) {
//     final now = tz.TZDateTime.now(tz.local);
//     var result = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);

//     while (result.weekday != dow) {
//       result = result.add(const Duration(days: 1));
//     }

//     if (result.isBefore(now)) {
//       result = result.add(const Duration(days: 7));
//     }
//     return result;
//   }

//   Future<void> cancelNotification(int id) async {
//     if (kIsWeb) return;
//     await flutterLocalNotificationsPlugin.cancel(id);
//   }
// }