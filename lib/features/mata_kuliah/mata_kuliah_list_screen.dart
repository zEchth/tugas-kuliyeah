// lib/features/mata_kuliah/mata_kuliah_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/add_edit_mata_kuliah_screen.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/mata_kuliah_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MataKuliahListScreen extends ConsumerWidget {
  const MataKuliahListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 'watch' stream provider-nya.
    final asyncMataKuliah = ref.watch(allMataKuliahProvider);

    // Mengambil nama user dari metadata
    final user = Supabase.instance.client.auth.currentUser;

    final userName = user?.userMetadata?['full_name'] ?? "Pengguna";
    final userPhoto =
        user?.userMetadata?['avatar_url'] ??
        user?.userMetadata?['picture']; // Google kadang pakai 'picture'

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            // FOTO PROFIL BULET PREMIUM
            Padding(
              padding: const EdgeInsets.only(
                left: 12,
              ), // <<––– MARGIN KIRI DI SINI
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                backgroundImage: userPhoto != null
                    ? NetworkImage(userPhoto)
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
          // tombol logout kamu tetap di sini
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
                              onPressed: () async {
                                Navigator.pop(context);
                                await Supabase.instance.client.auth.signOut();
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
