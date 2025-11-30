import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/add_edit_mata_kuliah_screen.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/mata_kuliah_detail_screen.dart';

// [REFACTOR] Screen ini sekarang bersih dari Logic Logout, Profil, & Notifikasi Permission
// Logic notifikasi dipindah ke MainNavigationScreen
// Logic Profil & Logout dipindah ke ProfileScreen

class MataKuliahListScreen extends ConsumerStatefulWidget {
  const MataKuliahListScreen({super.key});

  @override
  ConsumerState<MataKuliahListScreen> createState() =>
      _MataKuliahListScreenState();
}

class _MataKuliahListScreenState extends ConsumerState<MataKuliahListScreen> {
  // [SOLUSI] Local Temporary Filter -> DIPINDAHKAN KE GLOBAL PROVIDER
  // Menyimpan ID item yang sedang dihapus secara visual menunggu konfirmasi DB.
  // final Set<String> _tempDeletedIds = {};

  // Logic initState _checkPlatformAndPermission SUDAH DIPINDAHKAN ke main_navigation_screen.dart

  @override
  Widget build(BuildContext context) {
    // 'watch' stream provider-nya.
    final asyncMataKuliah = ref.watch(allMataKuliahProvider);

    // [SOLUSI] Ambil Global Ignore List dari Provider
    final ignoredIds = ref.watch(tempDeletedMataKuliahProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Text("Daftar Mata Kuliah"), // Judul sederhana
        automaticallyImplyLeading: false, // Hilangkan tombol back default
        actions: [
          // Tombol Inbox & Logout SUDAH DIPINDAHKAN ke ProfileScreen
        ],
      ),

      // Test notification (Code lama tetap dikomen sesuai permintaan)
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (listMataKuliah) {
          // [SOLUSI] Filter list menggunakan Global Provider
          // Ini mencegah Dismissible dirender ulang untuk item yang sedang dihapus
          final filteredList = listMataKuliah.where((matkul) {
            return !ignoredIds.contains(matkul.id);
          }).toList();

          if (filteredList.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada mata kuliah.\nTekan (+) untuk menambah.",
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            // Gunakan filteredList.length, bukan listMataKuliah.length
            itemCount: filteredList.length,
            padding: const EdgeInsets.only(bottom: 80), // Space for FAB
            itemBuilder: (context, index) {
              final matkul = filteredList[index];

              // --- Delete (Geser) ---
              return Dismissible(
                key: ValueKey(matkul.id), // Kunci unik
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  // [SOLUSI v3.0] Update state GLOBAL (Notifier)
                  // Agar item hilang dari tree saat ini juga (memuaskan Dismissible)
                  // dan tetap hilang jika layar di-rebuild
                  ref
                      .read(tempDeletedMataKuliahProvider.notifier)
                      .add(matkul.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${matkul.nama} dihapus")),
                  );

                  try {
                    // Panggil fungsi Delete dari repository (Async)
                    await ref
                        .read(taskRepositoryProvider)
                        .deleteMataKuliah(matkul.id);
                    // Jika sukses, Stream Supabase akan update otomatis nanti.
                    // Saat Stream update, ID matkul tersebut akan hilang permanen dari listMataKuliah.
                  } catch (e) {
                    // [SOLUSI v3.0] Jika Gagal, kembalikan item ke UI (Rollback Global)
                    ref
                        .read(tempDeletedMataKuliahProvider.notifier)
                        .remove(matkul.id);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gagal menghapus: $e")),
                      );
                    }
                  }
                },
                child: ListTile(
                  title: Text(matkul.nama),
                  subtitle: Text("${matkul.dosen} - ${matkul.sks} SKS"),
                  trailing: const Icon(Icons.chevron_right),

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
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Jangan kirim matkul untuk mode Add
              builder: (context) => const AddEditMataKuliahScreen(),
            ),
          );
        },
      ),
    );
  }
}