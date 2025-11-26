import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/autentikasi/login_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kuliyeah/core/providers.dart';
// IMPORT SERVICE
import 'package:tugas_kuliyeah/services/notification_service.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/mata_kuliah_list_screen.dart';

void main() async {
  // Pastikan binding siap sebelum menjalankan APP
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.init();

  // Perbaikan
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception(
      ".env tidak lengkap! SUPABASE_URL/SUPABASE_ANON_KEY hilang",
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

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

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;

        if (session == null) {
          return LoginPage();
        }

        return MataKuliahListScreen();
      },
    );
  }
}
