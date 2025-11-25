import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  await Supabase.initialize(
    url: 'https://zjpswhmhfvapcquscmvd.supabase.co', // Ganti dengan URL proyek Supabase Anda
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqcHN3aG1oZnZhcGNxdXNjbXZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM0NzE4NjEsImV4cCI6MjA3OTA0Nzg2MX0.kdJgx-4kbzM0HzDXgdyoZrW2g1aXA8ue8NQX0Mdf4d8',
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
        final session = snapshot.data?.session ?? 
            Supabase.instance.client.auth.currentSession;
        
        if (session == null) {
          return LoginPage();
        } 
          
        return MataKuliahListScreen();
      },
    );
  }
}
