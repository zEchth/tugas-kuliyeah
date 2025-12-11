import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class FcmTokenService {
  Future<void> saveFcmToken([String? newToken]) async {
    if (kIsWeb) return;

    // CEGAT BACKGROUND ISOLATE
    if (SchedulerBinding.instance == null || WidgetsBinding.instance == null) {
      print("BLOCKED → saveFcmToken dipanggil di BACKGROUND ISOLATE");
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print("BLOCKED → USER NULL");
      return;
    }

    final token = newToken ?? await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await Supabase.instance.client.from('fcm_tokens').upsert({
      'user_id': user.id,
      'token': token,
    }, onConflict: 'user_id');
  }
}
