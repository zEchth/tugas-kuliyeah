import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class FcmTokenService {
  Future<void> saveFcmToken([String? newToken]) async {
    if (kIsWeb) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final token = newToken ?? await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await Supabase.instance.client.from('fcm_tokens').upsert({
      'user_id': user.id,
      'token': token,
    }, onConflict: 'user_id');
  }
}
