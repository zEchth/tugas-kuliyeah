import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kuliyeah/core/providers.dart';
// IMPORT SERVICE
import 'package:tugas_kuliyeah/services/notification_service.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/mata_kuliah_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- INITALIZE NOTIFICATION SERVICE ---
  final notificationService = NotificationService();
  await notificationService.init();

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskTracker',
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: MataKuliahListScreen(),
    );
  }
}
