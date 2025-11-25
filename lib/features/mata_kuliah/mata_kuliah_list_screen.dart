import 'package:flutter/foundation.dart'; // Import ini WAJIB untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import library notifikasi untuk memanggil fungsi request permission
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/add_edit_mata_kuliah_screen.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/mata_kuliah_detail_screen.dart';

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

    return Scaffold(
      appBar: AppBar(title: Text("Mata Kuliah Saya")),
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
