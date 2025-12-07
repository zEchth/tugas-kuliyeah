import 'dart:math'; // Untuk warna random avatar
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

  // --- [BARU] Search Controller ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- [BARU] Helper Warna Avatar Konsisten ---
  Color _getAvatarColor(String nama) {
    final colors = [
      Colors.blueAccent,
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.green,
      Colors.teal,
      Colors.pinkAccent,
    ];
    // Gunakan hash dari string agar warnanya tetap sama untuk mata kuliah yang sama
    return colors[nama.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    // 'watch' stream provider-nya.
    final asyncMataKuliah = ref.watch(allMataKuliahProvider);

    // [SOLUSI] Ambil Global Ignore List dari Provider
    final ignoredIds = ref.watch(tempDeletedMataKuliahProvider);

    return Scaffold(
      // Background sangat gelap (mirip InboxSharedTaskScreen)
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        titleSpacing: 16,
        title: const Text(
          "Akademik",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false, // Hilangkan tombol back default
      ),

      body: asyncMataKuliah.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (listMataKuliah) {
          // [SOLUSI] 1. Filter list menggunakan Global Provider (Hapus Hantu)
          var filteredList = listMataKuliah.where((matkul) {
            return !ignoredIds.contains(matkul.id);
          }).toList();

          // [SOLUSI] 2. Filter Search Query
          if (_searchQuery.isNotEmpty) {
            filteredList = filteredList.where((mk) {
              return mk.nama
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  mk.dosen.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();
          }

          // [BARU] Hitung Statistik
          final totalSks = filteredList.fold(0, (sum, item) => sum + item.sks);
          final totalMatkul = filteredList.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER RINGKASAN ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent.withValues(alpha: 0.2),
                        const Color(0xFF1E1E1E),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                          "Total Mata Kuliah", "$totalMatkul", Icons.book),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildStatItem(
                          "Total SKS", "$totalSks", Icons.show_chart),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- SEARCH BAR ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Cari mata kuliah atau dosen...",
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- LIST CONTENT ---
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 60,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? "Belum ada mata kuliah.\nTekan (+) untuk mulai."
                                  : "Tidak ditemukan mata kuliah\n'$_searchQuery'",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white38),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredList.length,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final matkul = filteredList[index];

                          // --- Delete (Geser) ---
                          return Dismissible(
                            key: ValueKey(matkul.id), // Kunci unik
                            direction: DismissDirection.endToStart,

                            // Background transparan saat geser ke arah yang salah (jika ada)
                            background: Container(color: Colors.transparent),
                            // Background merah saat geser kanan-ke-kiri (Hapus)
                            secondaryBackground: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),

                            onDismissed: (direction) async {
                              // [SOLUSI v3.0] Update state GLOBAL (Notifier)
                              ref
                                  .read(tempDeletedMataKuliahProvider.notifier)
                                  .add(matkul.id);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${matkul.nama} dihapus"),
                                  action: SnackBarAction(
                                    label: "Batal",
                                    onPressed: () {
                                      // TODO: Implementasi Undo logic
                                    },
                                  ),
                                ),
                              );

                              try {
                                // Panggil fungsi Delete dari repository (Async)
                                await ref
                                    .read(taskRepositoryProvider)
                                    .deleteMataKuliah(matkul.id);
                              } catch (e) {
                                // [SOLUSI v3.0] Jika Gagal, kembalikan item ke UI (Rollback Global)
                                ref
                                    .read(
                                        tempDeletedMataKuliahProvider.notifier)
                                    .remove(matkul.id);

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Gagal menghapus: $e")),
                                  );
                                }
                              }
                            },
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                // --- Read (Detail) ---
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MataKuliahDetailScreen(
                                              matkul: matkul),
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
                                          AddEditMataKuliahScreen(
                                              matkul: matkul),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E1E),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Row(
                                    children: [
                                      // AVATAR INISIAL
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: _getAvatarColor(matkul.nama)
                                              .withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _getAvatarColor(matkul.nama)
                                                .withValues(alpha: 0.5),
                                            width: 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            matkul.nama.isNotEmpty
                                                ? matkul.nama[0].toUpperCase()
                                                : "?",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  _getAvatarColor(matkul.nama),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // CONTENT TEXT
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              matkul.nama,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.person_outline,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    matkul.dosen,
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // SKS BADGE
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.05),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              "${matkul.sks}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                            const Text(
                                              "SKS",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
            );
            },
          ),

      // --- Create ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
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

  // Widget Helper untuk Statistik Header
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blueAccent, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}