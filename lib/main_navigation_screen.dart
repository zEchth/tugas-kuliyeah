import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kuliyeah/features/home/home_screen.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/mata_kuliah_list_screen.dart';
import 'package:tugas_kuliyeah/features/profile/profile_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Daftar halaman untuk navigasi
  final List<Widget> _screens = [
    const HomeScreen(),
    const MataKuliahListScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Panggil fungsi pengecekan platform/notifikasi di sini (Level Aplikasi)
    // Dipindahkan dari MataKuliahListScreen agar hanya dipanggil sekali di awal.
    _checkPlatformAndPermission();
  }

  // Fungsi ini memisahkan logika menjadi 2 KASUS (Browser vs Emulator)
  Future<void> _checkPlatformAndPermission() async {
    if (kIsWeb) {
      // ==========================================
      // CASE 1: BROWSER (WEB)
      // ==========================================
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
      // ==========================================
      // CASE 2: EMULATOR / HP (ANDROID/iOS)
      // ==========================================
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
        // Style tambahan biar rapi di dark mode
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A1A),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}