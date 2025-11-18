// lib/features/mata_kuliah/mata_kuliah_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Impor intl
import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart' as core_model;
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/add_edit_jadwal_screen.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/add_edit_mata_kuliah_screen.dart';
// --- IMPOR BARU ---
import 'package:tugas_kuliyeah/features/tugas/add_edit_tugas_screen.dart';

class MataKuliahDetailScreen extends ConsumerWidget {
  final core_model.MataKuliah matkul;
  const MataKuliahDetailScreen({super.key, required this.matkul});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil stream jadwal SPESIFIK untuk matkul ini
    final asyncJadwal = ref.watch(jadwalByMatkulProvider(matkul.id));
    // --- AMBIL STREAM TUGAS ---
    final asyncTugas = ref.watch(tugasByMatkulProvider(matkul.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(matkul.nama),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: "Edit Mata Kuliah",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditMataKuliahScreen(matkul: matkul),
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
            Text(
              "Jadwal Kuliah",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // --- Daftar Jadwal (Read) ---
            Expanded(
              // Kita pakai 'flex' agar bisa punya 2 Expanded
              flex: 1,
              child: asyncJadwal.when(
                loading: () => Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error: $err")),
                data: (listJadwal) {
                  if (listJadwal.isEmpty) {
                    return Center(
                      child: Text(
                        "Belum ada jadwal.\nTekan (+) di bawah untuk menambah.",
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: listJadwal.length,
                    itemBuilder: (context, index) {
                      final jadwal = listJadwal[index];
                      // Format jam (sederhana)
                      final jamMulai =
                          "${jadwal.jamMulai.hour.toString().padLeft(2, '0')}:${jadwal.jamMulai.minute.toString().padLeft(2, '0')}";
                      final jamSelesai =
                          "${jadwal.jamSelesai.hour.toString().padLeft(2, '0')}:${jadwal.jamSelesai.minute.toString().padLeft(2, '0')}";

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
                          ref
                              .read(taskRepositoryProvider)
                              .deleteJadwal(jadwal.id);
                        },
                        child: Card(
                          child: ListTile(
                            title: Text("Hari: ${jadwal.hari}"),
                            subtitle: Text(
                              "$jamMulai - $jamSelesai | Ruang: ${jadwal.ruangan}",
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.edit_note,
                                color: Colors.grey[400],
                              ),
                              tooltip: "Edit Jadwal",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditJadwalScreen(
                                      mataKuliahId: matkul.id,
                                      jadwal: jadwal, // Kirim data jadwal
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // --- TAMBAHAN BARU (Fitur Tugas) ---
            Divider(height: 30),
            Text(
              "Daftar Tugas / Ujian",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // --- Daftar Tugas (Read) ---
            Expanded(
              flex: 1, // Beri 'flex' yang sama dengan jadwal
              child: asyncTugas.when(
                loading: () => Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error: $err")),
                data: (listTugas) {
                  if (listTugas.isEmpty) {
                    return Center(
                      child: Text(
                        "Belum ada tugas.\nTekan (+) di bawah untuk menambah.",
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: listTugas.length,
                    itemBuilder: (context, index) {
                      final tugas = listTugas[index];
                      final tenggat = DateFormat(
                        'dd MMM yyyy, HH:mm',
                      ).format(tugas.tenggatWaktu);

                      // --- Delete Tugas (Geser) ---
                      return Dismissible(
                        key: ValueKey(tugas.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          ref
                              .read(taskRepositoryProvider)
                              .deleteTugas(tugas.id);
                        },
                        child: Card(
                          color: Colors.blueGrey[900], // Bedakan warna Card
                          child: ListTile(
                            title: Text(
                              tugas.jenis,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "${tugas.deskripsi}\nTenggat: $tenggat",
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: Icon(
                                Icons.edit_note,
                                color: Colors.grey[400],
                              ),
                              tooltip: "Edit Tugas",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditTugasScreen(
                                      mataKuliahId: matkul.id,
                                      tugas: tugas, // Kirim data tugas
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // --- AKHIR TAMBAHAN BARU ---
          ],
        ),
      ),
      // --- MODIFIKASI FAB ---
      // Kita buat 2 FAB kecil dalam satu kolom
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab_tugas', // Tag unik
            child: Icon(Icons.add_task),
            tooltip: "Tambah Tugas/Ujian",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditTugasScreen(mataKuliahId: matkul.id),
                ),
              );
            },
          ),
          SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'fab_jadwal', // Tag unik
            child: Icon(Icons.alarm_add),
            tooltip: "Tambah Jadwal",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditJadwalScreen(mataKuliahId: matkul.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
