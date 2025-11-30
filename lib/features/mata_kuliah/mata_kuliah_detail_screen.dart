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

// [SOLUSI] Ubah ke ConsumerStatefulWidget agar bisa pakai setState untuk local filtering
class MataKuliahDetailScreen extends ConsumerStatefulWidget {
  final core_model.MataKuliah matkul;
  const MataKuliahDetailScreen({super.key, required this.matkul});

  @override
  ConsumerState<MataKuliahDetailScreen> createState() =>
      _MataKuliahDetailScreenState();
}

class _MataKuliahDetailScreenState
    extends ConsumerState<MataKuliahDetailScreen> {
  // [SOLUSI] Local Temporary Filters
  // Kita butuh 2 set terpisah karena di screen ini ada 2 list berbeda.
  final Set<String> _tempDeletedJadwalIds = {};
  final Set<String> _tempDeletedTugasIds = {};

  // Tambah
  Future<String?> _pickReceiver(BuildContext context, WidgetRef ref) async {
    final users = await ref.read(allUsersProvider.future);

    return await showDialog<String>(
      context: context,
      builder: (context) {
        String? selected;

        return AlertDialog(
          title: const Text("Pilih penerima"),
          content: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: "Pilih Email"),
            items: users.map((u) {
              final email = u['email'] as String;
              return DropdownMenuItem<String>(value: email, child: Text(email));
            }).toList(),
            onChanged: (value) {
              selected = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, selected),
              child: const Text("Kirim"),
            ),
          ],
        );
      },
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
  Widget build(BuildContext context) {
    // Ambil stream jadwal SPESIFIK untuk matkul ini
    // Gunakan widget.matkul karena sekarang kita di dalam State class
    final asyncJadwal = ref.watch(jadwalByMatkulProvider(widget.matkul.id));
    // --- AMBIL STREAM TUGAS ---
    final asyncTugas = ref.watch(tugasByMatkulProvider(widget.matkul.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.matkul.nama),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: "Edit Mata Kuliah",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditMataKuliahScreen(matkul: widget.matkul),
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
            Text(
                "Dosen: ${widget.matkul.dosen}",
                style: TextStyle(fontSize: 18)),
            Text("SKS: ${widget.matkul.sks}", style: TextStyle(fontSize: 18)),
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
                  // [SOLUSI] Filter List Jadwal
                  final filteredJadwal = listJadwal.where((j) {
                    return !_tempDeletedJadwalIds.contains(j.id);
                  }).toList();

                  if (filteredJadwal.isEmpty) {
                    return Center(
                      child: Text(
                        "Belum ada jadwal.\nTekan (+) di bawah untuk menambah.",
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredJadwal.length,
                    itemBuilder: (context, index) {
                      final jadwal = filteredJadwal[index];
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

                        onDismissed: (direction) async {
                          // [SOLUSI] Update UI lokal Jadwal
                          setState(() {
                            _tempDeletedJadwalIds.add(jadwal.id);
                          });

                          try {
                            await ref
                                .read(taskRepositoryProvider)
                                .deleteJadwal(jadwal.id);
                          } catch (e) {
                            // [SOLUSI] Rollback Jadwal jika gagal
                            if (mounted) {
                              setState(() {
                                _tempDeletedJadwalIds.remove(jadwal.id);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gagal hapus: $e")),
                              );
                            }
                          }
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
                                      mataKuliahId: widget.matkul.id,
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
                  // [SOLUSI] Filter List Tugas
                  final filteredTugas = listTugas.where((t) {
                    return !_tempDeletedTugasIds.contains(t.id);
                  }).toList();

                  if (filteredTugas.isEmpty) {
                    return Center(
                      child: Text(
                        "Belum ada tugas.\nTekan (+) di bawah untuk menambah.",
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredTugas.length,
                    itemBuilder: (context, index) {
                      final tugas = filteredTugas[index];
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
                        onDismissed: (direction) async {
                          // [SOLUSI] Update UI lokal Tugas
                          setState(() {
                            _tempDeletedTugasIds.add(tugas.id);
                          });

                          try {
                            await ref
                                .read(taskRepositoryProvider)
                                .deleteTugas(tugas.id);
                          } catch (e) {
                            // [SOLUSI] Rollback Tugas jika gagal
                            if (mounted) {
                              setState(() {
                                _tempDeletedTugasIds.remove(tugas.id);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gagal hapus: $e")),
                              );
                            }
                          }
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
                                      ref,
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
                                              mataKuliahId: widget.matkul.id,
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
                      AddEditTugasScreen(mataKuliahId: widget.matkul.id),
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
                      AddEditJadwalScreen(mataKuliahId: widget.matkul.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}