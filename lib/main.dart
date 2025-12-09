import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // Tambahan
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:tugas_kuliyeah/services/notification_service.dart';
import 'package:tugas_kuliyeah/main_navigation_screen.dart';
import 'features/autentikasi/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Environment Variables
  await dotenv.load(fileName: ".env");

  // 2. Inisialisasi Firebase (Khusus Web perlu options manual)
  // GANTI NILAI DI BAWAH DENGAN DATA DARI FIREBASE CONSOLE
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyD0QN7tBiABOfNzAUAQ3F82Yf2POSXloYg",
      authDomain: "tasktracker-131c8.firebaseapp.com",
      projectId: "tasktracker-131c8",
      storageBucket: "tasktracker-131c8.firebasestorage.app",
      messagingSenderId: "474399573688",
      appId: "1:474399573688:web:cabdbe3d0428c8d26f164d",
      measurementId: "G-VQGMNQ612S",
    ),
  );

  // 3. Inisialisasi Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception(".env tidak lengkap!");
  }
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // 4. Inisialisasi Notification Service
  final notificationService = NotificationService();
  // Kita panggil init() nanti saja setelah login atau di AuthGate, 
  // tapi instance-nya kita siapkan sekarang.

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const MyApp(),
    ),
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
      home: const AuthGate(),
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

  @override
  void initState() {
    super.initState();
    _session = Supabase.instance.client.auth.currentSession;
    
    // Cek session awal
    if (_session != null) {
      _initNotification(_session!.user.id);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _loading = false);
    });

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        // User baru login -> Jalankan notifikasi & simpan token
        _initNotification(session.user.id);
      }
      
      if (event == AuthChangeEvent.signedOut) {
         // Reset state riverpod saat logout
         ref.invalidate(allMataKuliahProvider);
         ref.invalidate(jadwalByMatkulProvider);
         ref.invalidate(tugasByMatkulProvider);
         ref.invalidate(taskRepositoryProvider);
      }

      setState(() {
        _session = session;
      });
    });
  }

  // Fungsi helper untuk init notifikasi
  void _initNotification(String userId) async {
    final notifService = ref.read(notificationServiceProvider);
    await notifService.init(); // Request permission
    await notifService.uploadFcmToken(userId); // Simpan token ke DB
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (_session == null) {
      return LoginPage();
    }

    return const MainNavigationScreen();
  }
}