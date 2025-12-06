// lib/features/mata_kuliah/mata_kuliah_detail_screen.dart
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart'
    show kIsWeb; // [AUDITOR] Penting untuk deteksi platform
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart'; // [AUDITOR] Tambahan wajib untuk Web
import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart' as core_model;
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:tugas_kuliyeah/core/models/tugas.dart'
    as core_model; // Import model tugas
import 'package:tugas_kuliyeah/core/models/jadwal.dart'
    as core_model; // Import model jadwal
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
  // [SOLUSI] Local Temporary Filters -> DIPINDAHKAN KE GLOBAL PROVIDER
  // Kita tidak lagi menggunakan Set lokal agar state tetap tersimpan saat pindah halaman.
  // final Set<String> _tempDeletedJadwalIds = {};
  // final Set<String> _tempDeletedTugasIds = {};

  Future<String> downloadToTemp(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Download gagal");
    }

    final bytes = response.bodyBytes;

    final tempDir = await getTemporaryDirectory();
    final fileName = url.split('/').last;

    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    return file.path;
  }

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
  void _openAttachment(BuildContext context, String url) async {
    debugPrint("[DEBUG] Mencoba membuka file di path: $url");

    try {
      if (kIsWeb) {
        await launchUrl(Uri.parse(url));
        return;
      }

      // ANDROID / IOS => download dulu
      final temp = await downloadToTemp(url);

      final result = await OpenFilex.open(temp);

      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } catch (e) {
      debugPrint("[ERROR] Gagal membuka file: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal buka file: $e")));
      }
    }

    // try {
    //   if (kIsWeb) {
    //     // [KONSTRUKTOR] Logika Khusus Web
    //     // Di Web, path dari file_picker biasanya berupa Blob URL (blob:http://...)
    //     // Kita harus menggunakan url_launcher untuk membukanya di tab browser.
    //     final Uri uri = Uri.parse(path);

    //     // Kita coba launch langsung. Browser modern mungkin memblokir ini jika
    //     // tidak dipicu langsung oleh user gesture, tapi onTap adalah user gesture.
    //     if (await canLaunchUrl(uri)) {
    //       await launchUrl(uri);
    //     } else {
    //       // Fallback: Terkadang canLaunchUrl return false untuk blob,
    //       // tapi launchUrl tetap berhasil. Kita coba paksa.
    //       debugPrint("[DEBUG] canLaunchUrl false, mencoba paksa launchUrl...");
    //       await launchUrl(uri);
    //     }
    //   } else {
    //     // [KONSTRUKTOR] Logika Mobile (Android/iOS)
    //     // OpenFilex bekerja sangat baik di mobile dengan path fisik storage.
    //     final result = await OpenFilex.open(path);
    //     debugPrint(
    //       "[DEBUG] Hasil OpenFilex: ${result.type} - ${result.message}",
    //     );

    //     if (result.type != ResultType.done) {
    //       throw Exception(result.message);
    //     }
    //   }
    // } catch (e) {
    //   // Error Handling Terpusat
    //   debugPrint("[ERROR] Gagal membuka file: $e");
    //   if (context.mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text("Gagal buka file: $e"),
    //         backgroundColor: Colors.red,
    //         duration: Duration(seconds: 3),
    //       ),
    //     );
    //   }
    // }
  }

  // [UX UPDATE] Bottom Sheet untuk Detail Jadwal (Konsisten dengan Home)
  void _showJadwalDetail(core_model.Jadwal jadwal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar bisa lebih tinggi jika konten banyak
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Detail Jadwal",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  _StatusBadge(status: jadwal.getStatus(DateTime.now())),
                ],
              ),
              const SizedBox(height: 16),

              // Info
              _buildDetailRow(Icons.calendar_today, jadwal.hari),
              _buildDetailRow(
                Icons.access_time,
                "${DateFormat('HH:mm').format(jadwal.jamMulai)} - ${DateFormat('HH:mm').format(jadwal.jamSelesai)}",
              ),
              _buildDetailRow(
                Icons.location_on,
                jadwal.ruangan ?? "Tidak ada ruangan",
              ),
              _buildDetailRow(Icons.school, widget.matkul.dosen),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit"),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditJadwalScreen(
                              mataKuliahId: widget.matkul.id,
                              jadwal: jadwal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Tutup"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // [UX UPDATE] Bottom Sheet untuk Detail Tugas (Konsisten dengan Home)
  void _showTugasDetail(core_model.Tugas tugas) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref2, _) {
            final attachmentsAsync = ref2.watch(
              attachmentsByTaskProvider(tugas.id),
            );

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== HEADER TITLE + EDIT BUTTON =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            tugas.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: "Edit Tugas",
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEditTugasScreen(
                                  mataKuliahId: widget.matkul.id,
                                  tugas: tugas,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    Text(
                      widget.matkul.nama,
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Status Pengerjaan:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      children:
                          [
                            "Belum Dikerjakan",
                            "Dalam Pengerjaan",
                            "Selesai",
                          ].map((status) {
                            final isSelected = tugas.status == status;
                            return ChoiceChip(
                              label: Text(status),
                              selected: isSelected,
                              onSelected: (selected) async {
                                if (selected) {
                                  Navigator.pop(context);
                                  try {
                                    await ref
                                        .read(taskRepositoryProvider)
                                        .updateTugas(
                                          tugas.copyWith(status: status),
                                        );

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Status diupdate: $status",
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (_) {}
                                }
                              },
                            );
                          }).toList(),
                    ),

                    if (tugas.note != null && tugas.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text("Catatan:\n${tugas.note}"),
                      ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Deadline: ${DateFormat('dd MMM yyyy, HH:mm').format(tugas.dueAt)}",
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ===== ATTACHMENTS =====
                    attachmentsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Text("Gagal memuat lampiran"),
                      data: (list) {
                        if (list.isEmpty) {
                          return const Text(
                            "Tidak ada lampiran",
                            style: TextStyle(color: Colors.grey),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Lampiran:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...list.map((att) {
                              final fileName = att.path.split('/').last;
                              return ListTile(
                                leading: const Icon(Icons.attach_file),
                                title: Text(
                                  fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  if (att.url == null || att.url!.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "URL file tidak tersedia",
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  _openAttachment(context, att.url!);
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  // --- Helper Icon Tugas (Sama dengan Home) ---
  IconData _getTaskIcon(String type) {
    switch (type.toLowerCase()) {
      case 'kuis':
        return Icons.quiz;
      case 'uts':
        return Icons.history_edu;
      case 'uas':
        return Icons.school;
      default:
        return Icons.assignment;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil stream jadwal SPESIFIK untuk matkul ini
    // Gunakan widget.matkul karena sekarang kita di dalam State class
    final asyncJadwal = ref.watch(jadwalByMatkulProvider(widget.matkul.id));
    // --- AMBIL STREAM TUGAS ---
    final asyncTugas = ref.watch(tugasByMatkulProvider(widget.matkul.id));

    // [SOLUSI] Ambil Global Ignore List dari Provider
    final ignoredJadwalIds = ref.watch(tempDeletedJadwalProvider);
    final ignoredTugasIds = ref.watch(tempDeletedTugasProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.matkul.nama),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
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
            // --- Info Mata Kuliah (Card Style) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blueAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 18,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Dosen: ${widget.matkul.dosen}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.book,
                        size: 18,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 8),
                      Text("SKS: ${widget.matkul.sks}"),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 30),

            // --- Judul Daftar Jadwal ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Jadwal Kuliah",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
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

            // --- Daftar Jadwal (Read) ---
            Expanded(
              // Kita pakai 'flex' agar bisa punya 2 Expanded
              flex: 1,
              child: asyncJadwal.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error: $err")),
                data: (listJadwal) {
                  // [SOLUSI] Filter List Jadwal menggunakan Global Provider
                  final filteredJadwal = listJadwal.where((j) {
                    return !ignoredJadwalIds.contains(j.id);
                  }).toList();

                  if (filteredJadwal.isEmpty) {
                    return Center(
                      child: Text(
                        "Belum ada jadwal.",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredJadwal.length,
                    itemBuilder: (context, index) {
                      final jadwal = filteredJadwal[index];
                      final jamMulai = DateFormat(
                        'HH:mm',
                      ).format(jadwal.jamMulai);
                      final jamSelesai = DateFormat(
                        'HH:mm',
                      ).format(jadwal.jamSelesai);

                      // Status Realtime
                      final status = jadwal.getStatus(DateTime.now());

                      // --- Delete Jadwal (Geser) ---
                      return Dismissible(
                        key: ValueKey(jadwal.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),

                        onDismissed: (direction) async {
                          // [SOLUSI v3.0] Update UI Global State (Optimistic)
                          ref
                              .read(tempDeletedJadwalProvider.notifier)
                              .add(jadwal.id);

                          try {
                            await ref
                                .read(taskRepositoryProvider)
                                .deleteJadwal(jadwal.id);
                          } catch (e) {
                            // [SOLUSI v3.0] Rollback Jadwal jika gagal
                            ref
                                .read(tempDeletedJadwalProvider.notifier)
                                .remove(jadwal.id);

                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gagal hapus: $e")),
                              );
                            }
                          }
                        },

                        // [UI UPDATE] Menggunakan Styling mirip Home Screen
                        child: GestureDetector(
                          onTap: () => _showJadwalDetail(jadwal),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E), // Dark card
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                // Kolom Waktu
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        jadwal.hari
                                            .substring(0, 3)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Detail
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "$jamMulai - $jamSelesai",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          _StatusBadge(status: status), // Badge
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            jadwal.ruangan ?? "Ruang -",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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

            // --- TAMBAHAN BARU (Fitur Tugas) ---
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daftar Tugas",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_task, color: Colors.blueAccent),
                  tooltip: "Tambah Tugas",
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
              ],
            ),

            // --- Daftar Tugas (Read) ---
            Expanded(
              flex: 1, // Beri 'flex' yang sama dengan jadwal
              child: asyncTugas.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error: $err")),
                data: (listTugas) {
                  // [SOLUSI] Filter List Tugas menggunakan Global Provider
                  final filteredTugas = listTugas.where((t) {
                    return !ignoredTugasIds.contains(t.id);
                  }).toList();

                  // Sort by deadline
                  filteredTugas.sort((a, b) => a.dueAt.compareTo(b.dueAt));

                  if (filteredTugas.isEmpty) {
                    return Center(
                      child: Text(
                        "Tidak ada tugas.",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredTugas.length,
                    itemBuilder: (context, index) {
                      final tugas = filteredTugas[index];

                      // Cek Urgency (Logic sama dengan Home)
                      final timeLeft = tugas.dueAt.difference(DateTime.now());
                      final isUrgent =
                          timeLeft.inDays < 2 &&
                          !timeLeft.isNegative &&
                          tugas.status != 'Selesai';
                      Color cardColor = const Color(0xFF1E1E1E); // Default Dark
                      if (isUrgent) {
                        cardColor = Colors.redAccent.withValues(alpha: 0.1);
                      }

                      // --- Delete Tugas (Geser) ---
                      return Dismissible(
                        key: ValueKey(tugas.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) async {
                          // [SOLUSI v3.0] Update UI Global State (Optimistic)
                          ref
                              .read(tempDeletedTugasProvider.notifier)
                              .add(tugas.id);

                          try {
                            await ref
                                .read(taskRepositoryProvider)
                                .deleteTugas(tugas.id);
                          } catch (e) {
                            // [SOLUSI v3.0] Rollback Tugas jika gagal
                            ref
                                .read(tempDeletedTugasProvider.notifier)
                                .remove(tugas.id);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gagal hapus: $e")),
                              );
                            }
                          }
                        },

                        // [UI UPDATE] Menggunakan Styling mirip Home Screen
                        child: Card(
                          color: cardColor,
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            onTap: () =>
                                _showTugasDetail(tugas), // Buka Bottom Sheet
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent.withValues(
                                alpha: 0.1,
                              ),
                              child: Icon(
                                _getTaskIcon(tugas.type),
                                color: Colors.blueAccent,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              tugas.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: tugas.status == 'Selesai'
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: tugas.status == 'Selesai'
                                    ? Colors.grey
                                    : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      size: 12,
                                      color: isUrgent
                                          ? Colors.redAccent
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat(
                                        'dd MMM, HH:mm',
                                      ).format(tugas.dueAt),
                                      style: TextStyle(
                                        color: isUrgent
                                            ? Colors.redAccent
                                            : Colors.grey,
                                        fontSize: 12,
                                        fontWeight: isUrgent
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: _StatusBadgeMini(
                                          status: tugas.status,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Action Share dipindah ke trailing
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.share,
                                size: 20,
                                color: Colors.blueAccent,
                              ),
                              tooltip: "Bagikan Tugas",
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
                                    content: Text("Dikirim ke $receiverEmail"),
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
      // Karena kita sudah memindahkan tombol "Tambah" ke samping Judul Section,
      // Kita bisa menghapus FAB agar layar lebih bersih dan tidak menutupi list paling bawah.
      // Namun jika Anda ingin tetap ada, bisa uncomment kode di bawah.

      // floatingActionButton: Column(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [ ... ],
      // ),
    );
  }
}

// [WIDGET REUSABLE] Copy dari HomeScreen agar konsisten
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;

    // Tentukan warna berdasarkan string status
    switch (status) {
      case "Mendatang":
      case "Belum Dikerjakan":
        color = Color(0xFFE0C9A6);
        break;
      case "Berlangsung":
      case "Dalam Pengerjaan":
        color = Colors.blueAccent;
        break;
      case "Selesai":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusBadgeMini extends StatelessWidget {
  final String status;
  const _StatusBadgeMini({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (status == "Dalam Pengerjaan") color = Colors.blueAccent;
    if (status == "Selesai") color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 9)),
    );
  }
}
