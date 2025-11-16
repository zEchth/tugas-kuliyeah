// lib/features/mata_kuliah/mata_kuliah_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart' as core_model;
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/add_edit_jadwal_screen.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/add_edit_mata_kuliah_screen.dart';
// import 'package:intl/intl.dart'; // Nanti perlukan ini untuk format jam

class MataKuliahDetailScreen extends ConsumerWidget {
  final core_model.MataKuliah matkul;
  const MataKuliahDetailScreen({super.key, required this.matkul});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil stream jadwal SPESIFIK untuk matkul ini
    final asyncJadwal = ref.watch(jadwalByMatkulProvider(matkul.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(matkul.nama),
        actions: [
          // --- PERUBAHAN DI SINI (Tombol Edit Matkul) ---
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: "Edit Mata Kuliah",
            onPressed: () {
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Info Mata Kuliah ---
            Text("Dosen: ${matkul.dosen}", style: TextStyle(fontSize: 18)),
            Text("SKS: ${matkul.sks}", style: TextStyle(fontSize: 18)),
            Divider(height: 30),

            // --- Judul Daftar Jadwal ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Jadwal Kuliah",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                // Tombol 'Add' tidak perlu, kita pakai FAB
              ],
            ),

            // --- Daftar Jadwal (Read) ---
            Expanded(
              child: asyncJadwal.when(
                loading: () => Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error: $err")),
                data: (listJadwal) {
                  if (listJadwal.isEmpty) {
                    return Center(child: Text("Belum ada jadwal.\nTekan (+) untuk menambah."));
                  }
                  return ListView.builder(
                    itemCount: listJadwal.length,
                    itemBuilder: (context, index) {
                      final jadwal = listJadwal[index];
                      // Format jam (sederhana)
                      final jamMulai = "${jadwal.jamMulai.hour.toString().padLeft(2,'0')}:${jadwal.jamMulai.minute.toString().padLeft(2,'0')}";
                      final jamSelesai = "${jadwal.jamSelesai.hour.toString().padLeft(2,'0')}:${jadwal.jamSelesai.minute.toString().padLeft(2,'0')}";

                      // --- Delete Jadwal (Geser) ---
                      return Dismissible(
                        key: ValueKey(jadwal.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          ref.read(taskRepositoryProvider).deleteJadwal(jadwal.id);
                        },
                        child: Card(
                          child: ListTile(
                            title: Text("Hari: ${jadwal.hari}"),
                            subtitle: Text("$jamMulai - $jamSelesai | Ruang: ${jadwal.ruangan}"),
                            
                            // --- Update Jadwal ---
                            trailing: IconButton(
                              icon: Icon(Icons.edit_note, color: Colors.grey[400]),
                              tooltip: "Edit Jadwal",
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => AddEditJadwalScreen(
                                      mataKuliahId: matkul.id,
                                      jadwal: jadwal, // Kirim data jadwal
                                    ),
                                  ));
                              },
                            ),
                            onLongPress: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => AddEditJadwalScreen(
                                  mataKuliahId: matkul.id,
                                  jadwal: jadwal, // Kirim data jadwal
                                ),
                              ));
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // --- Create Jadwal ---
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.alarm_add),
        tooltip: "Tambah Jadwal",
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => AddEditJadwalScreen(
              mataKuliahId: matkul.id,
              // Jangan kirim jadwal untuk mode Add
            ),
          ));
        },
      ),
    );
  }
}