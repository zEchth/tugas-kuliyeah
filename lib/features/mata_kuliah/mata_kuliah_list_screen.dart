import 'package:flutter/foundation.dart'; // Import ini WAJIB untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import library notifikasi untuk memanggil fungsi request permission
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/add_edit_mata_kuliah_screen.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/mata_kuliah_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tugas_kuliyeah/features/tugas/inbox_shared_task_screen.dart';

class MataKuliahListScreen extends ConsumerStatefulWidget {
  const MataKuliahListScreen({super.key});

  @override
  ConsumerState<MataKuliahListScreen> createState() =>
      _MataKuliahListScreenState();
}

class _MataKuliahListScreenState extends ConsumerState<MataKuliahListScreen> {
  @override
  void initState() {
    super.initState();

    // Panggil fungsi pengecekan platform saat layar dibuka
    _checkPlatformAndPermission();
  }

  // Fungsi ini memisahkan logika menjadi 2 KASUS (Browser vs Emulator)
  Future<void> _checkPlatformAndPermission() async {
    if (kIsWeb) {
      // ==========================================
      // CASE 1: BROWSER (WEB)
      // ==========================================
      // Di Web, kita tidak bisa menjadwalkan alarm.
      // Kita hanya memberi tahu user bahwa fitur ini non-aktif.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orange[800],
              behavior: SnackBarBehavior.floating,
              content: Row(
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
              duration: Duration(seconds: 5),
            ),
          );
        }
      });
    } else {
      // ==========================================
      // CASE 2: EMULATOR / HP (ANDROID/iOS)
      // ==========================================
      // Di Mobile, kita jalankan logika native untuk meminta izin notifikasi.
      // Ini wajib untuk Android 13 ke atas.
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 'watch' stream provider-nya.
    final asyncMataKuliah = ref.watch(allMataKuliahProvider);

    // Mengambil nama user dari metadata
    final user = Supabase.instance.client.auth.currentUser;

    final userName = user?.userMetadata?['full_name'] ?? "Pengguna";
    final userPhoto =
        user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture'];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            // FOTO PROFIL BULET PREMIUM
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                backgroundImage: userPhoto != null
                    ? CachedNetworkImageProvider(userPhoto)
                    : null,
                child: userPhoto == null
                    ? Icon(Icons.person, color: Colors.white70)
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            // NAMA USER
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hai, $userName",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Mata Kuliah Saya",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          // ====== INBOX BUTTON DI SINI ======
          IconButton(
            icon: const Icon(Icons.inbox),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InboxSharedTaskScreen(),
                ),
              );
            },
          ),

          // ====== LOGOUT BUTTON ======
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 200),
            tween: Tween(begin: 1.0, end: 1.0),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFF1A1A1A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          title: const Text(
                            "Logout?",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          content: Text(
                            "Apakah kamu yakin ingin keluar?",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Batal",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),

                              // masalah
                              onPressed: () async {
                                Navigator.pop(context);
                                try {
                                  ref.invalidate(allMataKuliahProvider);
                                  ref.invalidate(jadwalByMatkulProvider);
                                  ref.invalidate(tugasByMatkulProvider);
                                  ref.invalidate(taskRepositoryProvider);
                                  await Supabase.instance.client.auth.signOut();
                                } catch (e) {
                                  print("Logout error: $e");
                                }
                              },
                              child: const Text(
                                "Logout",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 14),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // Test notification
      // body: Column(
      //   children: [
      //     // === TOMBOL TEST NOTIF DI SINI ===
      //     Padding(
      //       padding: const EdgeInsets.all(12),
      //       child: ElevatedButton(
      //         onPressed: () {
      //           ref.read(notificationServiceProvider).testImmediateNotif();
      //         },
      //         child: const Text("TEST NOTIF"),
      //       ),
      //     ),

      //     // Expanded biar ListView tetap tampil
      //     Expanded(
      //       child: asyncMataKuliah.when(
      //         loading: () => Center(child: CircularProgressIndicator()),
      //         error: (err, stack) => Center(child: Text("Error: $err")),
      //         data: (listMataKuliah) {
      //           if (listMataKuliah.isEmpty) {
      //             return Center(
      //               child: Text(
      //                 "Belum ada mata kuliah.\nTekan (+) untuk menambah.",
      //                 textAlign: TextAlign.center,
      //               ),
      //             );
      //           }

      //           return ListView.builder(
      //             itemCount: listMataKuliah.length,
      //             itemBuilder: (context, index) {},
      //           );
      //         },
      //       ),
      //     ),
      //   ],
      // ),
      body: asyncMataKuliah.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (listMataKuliah) {
          if (listMataKuliah.isEmpty) {
            return Center(
              child: Text(
                "Belum ada mata kuliah.\nTekan (+) untuk menambah.",
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: listMataKuliah.length,
            itemBuilder: (context, index) {
              final matkul = listMataKuliah[index];

              // --- Delete (Geser) ---
              return Dismissible(
                key: ValueKey(matkul.id), // Kunci unik
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  // Panggil fungsi Delete dari repository
                  ref.read(taskRepositoryProvider).deleteMataKuliah(matkul.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${matkul.nama} dihapus")),
                  );
                },
                child: ListTile(
                  title: Text(matkul.nama),
                  subtitle: Text("${matkul.dosen} - ${matkul.sks} SKS"),
                  trailing: Icon(Icons.chevron_right),

                  // --- Read (Detail) ---
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MataKuliahDetailScreen(matkul: matkul),
                      ),
                    );
                  },

                  // --- Update (Tahan Lama) ---
                  onLongPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Kirim matkul untuk mode Edit
                        builder: (context) =>
                            AddEditMataKuliahScreen(matkul: matkul),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      // --- Create ---
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Jangan kirim matkul untuk mode Add
              builder: (context) => AddEditMataKuliahScreen(),
            ),
          );
        },
      ),
    );
  }
}
