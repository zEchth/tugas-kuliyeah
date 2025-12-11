import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/autentikasi/login_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kuliyeah/core/providers.dart';
// IMPORT SERVICE
import 'package:tugas_kuliyeah/services/notification_service.dart';
// [UPDATE] Import MainNavigationScreen
import 'package:tugas_kuliyeah/main_navigation_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tugas_kuliyeah/services/fcm_token_service.dart';

void main() async {
  // Pastikan binding siap sebelum menjalankan APP
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();

  if (!kIsWeb) {
    await notificationService.init();
  }

  // Perbaikan
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception(
      ".env tidak lengkap! SUPABASE_URL/SUPABASE_ANON_KEY hilang",
    );
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  if (!kIsWeb) {
    await Firebase.initializeApp();
  }

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    ProviderScope(
      // INJECT SERVICE KE RIVERPOD DI SINI
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  NotificationService().showNotification(
    title: message.notification?.title ?? 'No Title',
    body: message.notification?.body ?? 'No Body',
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'TaskTracker',
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,

      // home: MataKuliahListScreen(),
      home: AuthGate(),
    );
  }
}

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  Session? _session;
  bool _loading = true;

  StreamSubscription<String>? _tokenSub;
  late final StreamSubscription<AuthState> _authSub;

  late final FcmTokenService fcmService;

  @override
  void initState() {
    super.initState();

    fcmService = FcmTokenService();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        ref
            .read(notificationServiceProvider)
            .showNotification(
              title: notification.title ?? 'No Title',
              body: notification.body ?? 'No Body',
            );
      }
    });

    _session = Supabase.instance.client.auth.currentSession;

    // LISTEN TOKEN REFRESH (WAJIB)
    if (!kIsWeb) {
      _tokenSub = FirebaseMessaging.instance.onTokenRefresh.listen(
        fcmService.saveFcmToken,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _loading = false);
    });

    // LISTEN AUTH CHANGE (WAJIB)
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      final newSession = data.session;

      
      // [PERBAIKAN] Jika sesi hilang (User logout atau Token Expired)
      if (newSession == null) {
        // Pastikan notifikasi dibersihkan otomatis
        ref.read(notificationServiceProvider).cancelAllNotifications();
      } else {
        if (!kIsWeb) fcmService.saveFcmToken();
      }

      // reset SEMUA providers ketika user berganti
      ref.invalidate(allMataKuliahProvider);
      ref.invalidate(jadwalByMatkulProvider);
      ref.invalidate(tugasByMatkulProvider);
      ref.invalidate(taskRepositoryProvider);

      setState(() {
        _session = newSession;
        _loading = false;
      });
    });

    _loading = false;
  }

  @override
  void dispose() {
    _tokenSub?.cancel();
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_session == null) {
      return LoginPage();
    }

    // [UPDATE] Arahkan ke MainNavigationScreen, bukan MataKuliahListScreen langsung
    return const MainNavigationScreen();
  }
}
