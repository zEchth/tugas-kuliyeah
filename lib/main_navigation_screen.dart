import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kuliyeah/features/home/home_screen.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/mata_kuliah_list_screen.dart';
import 'package:tugas_kuliyeah/features/profile/profile_screen.dart';
// [UPDATE] Import Provider & Repo Type
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:tugas_kuliyeah/data/remote/repositories/supabase_task_repository.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MataKuliahListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkPlatformAndPermission();
    
    // [UPDATE] Trigger Sync Notification saat App Dibuka
    // Kita jalankan setelah frame pertama agar tidak blocking UI awal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNotifications();
    });
  }

  Future<void> _syncNotifications() async {
    if (kIsWeb) return; // Web tidak butuh sync local notif
    
    // Kita cek apakah repository yang aktif adalah SupabaseTaskRepository
    // Karena kita butuh method khusus 'resyncLocalNotifications' yang ada disana
    final repo = ref.read(taskRepositoryProvider);
    
    if (repo is SupabaseTaskRepository) {
      // Jalankan di background (async)
      repo.resyncLocalNotifications();
    }
  }

  Future<void> _checkPlatformAndPermission() async {
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orange[800],
              behavior: SnackBarBehavior.floating,
              content: const Row(
                children: [
                  Icon(
                    Icons.public,
                    color: Colors.white,
                  ), // Icon Globe untuk Web
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Mode Browser Terdeteksi",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Fitur Notifikasi Alarm tidak akan berjalan di sini.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      });
    } else {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menampilkan halaman sesuai index yang dipilih
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Mata Kuliah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A1A),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}