// lib/features/mata_kuliah/mata_kuliah_detail_screen.dart
import 'package:flutter/foundation.dart'
    show kIsWeb; // [AUDITOR] Penting untuk deteksi platform
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart'; // [AUDITOR] Tambahan wajib untuk Web
import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart' as core_model;
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/add_edit_jadwal_screen.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/add_edit_mata_kuliah_screen.dart';
import 'package:tugas_kuliyeah/features/tugas/add_edit_tugas_screen.dart';

class MataKuliahDetailScreen extends ConsumerWidget {
  final core_model.MataKuliah matkul;
  const MataKuliahDetailScreen({super.key, required this.matkul});

  // Tambah
  Future<String?> _pickReceiver(BuildContext context) async {
    final controller = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Share ke Email"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: "Masukkan email penerima"),
        ),
        actions: [
          TextButton(
            child: Text("Batal"),
            onPressed: () => Navigator.pop(context, null),
          ),
          TextButton(
            child: Text("Kirim"),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
          ),
        ],
      ),
    );
  }

  // --- BAGIAN EKA: Fungsi Buka File dengan Logika Cross-Platform ---
  void _openAttachment(BuildContext context, String path) async {
    debugPrint("[DEBUG] Mencoba membuka file di path: $path");

    try {
      if (kIsWeb) {
        // [KONSTRUKTOR] Logika Khusus Web
        // Di Web, path dari file_picker biasanya berupa Blob URL (blob:http://...)
        // Kita harus menggunakan url_launcher untuk membukanya di tab browser.
        final Uri uri = Uri.parse(path);

        // Kita coba launch langsung. Browser modern mungkin memblokir ini jika
        // tidak dipicu langsung oleh user gesture, tapi onTap adalah user gesture.
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          // Fallback: Terkadang canLaunchUrl return false untuk blob,
          // tapi launchUrl tetap berhasil. Kita coba paksa.
          debugPrint("[DEBUG] canLaunchUrl false, mencoba paksa launchUrl...");
          await launchUrl(uri);
        }
      } else {
        // [KONSTRUKTOR] Logika Mobile (Android/iOS)
        // OpenFilex bekerja sangat baik di mobile dengan path fisik storage.
        final result = await OpenFilex.open(path);
        debugPrint(
          "[DEBUG] Hasil OpenFilex: ${result.type} - ${result.message}",
        );

        if (result.type != ResultType.done) {
          throw Exception(result.message);
        }
      }
    } catch (e) {
      // Error Handling Terpusat
      debugPrint("[ERROR] Gagal membuka file: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal buka file: $e"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

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
                      ).format(tugas.dueAt);

                      // Cek apakah ada attachment
                      final bool hasAttachment =
                          tugas.attachmentPath != null &&
                          tugas.attachmentPath!.isNotEmpty;

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
                              tugas.type,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${tugas.note}\nTenggat: $tenggat"),
                                // Jika ada file, tampilkan indikator
                                if (hasAttachment)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.attach_file,
                                          size: 14,
                                          color: Colors.blueAccent,
                                        ),
                                        Text(
                                          " Ada Lampiran",
                                          style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            isThreeLine: true,
                            // Jika ada file, tap pada list akan membuka file
                            // Jika tidak, tidak melakukan apa-apa
                            onTap: hasAttachment
                                ? () => _openAttachment(
                                    context,
                                    tugas.attachmentPath!,
                                  )
                                : null,

                            // ubah
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.share,
                                    color: Colors.blueAccent,
                                  ),
                                  onPressed: () async {
                                    final receiverEmail = await _pickReceiver(
                                      context,
                                    );
                                    if (receiverEmail == null) return;

                                    await ref
                                        .read(taskRepositoryProvider)
                                        .shareTugas(
                                          tugasId: tugas.id,
                                          receiverEmail: receiverEmail,
                                        );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Tugas dibagikan ke $receiverEmail",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_note,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddEditTugasScreen(
                                              mataKuliahId: matkul.id,
                                              tugas: tugas,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ],
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
