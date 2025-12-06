import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:tugas_kuliyeah/core/models/tugas.dart' as core_model;
import 'package:tugas_kuliyeah/core/models/jadwal.dart' as core_model;
import 'package:tugas_kuliyeah/features/mata_kuliah/mata_kuliah_detail_screen.dart'; // Untuk Navigasi

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // State untuk filter hari (Default hari ini)
  late String _selectedDay;
  final List<String> _days = [
    "Senin",
    "Selasa",
    "Rabu",
    "Kamis",
    "Jumat",
    "Sabtu",
    "Minggu"
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    // Set default ke hari ini
    final now = DateTime.now();
    _selectedDay = _getDayName(now.weekday);
  }

  String _getDayName(int weekday) {
    // DateTime weekday: 1=Mon, 7=Sun
    return _days[weekday - 1];
  }

  // Helper untuk format tanggal header
  String _getHeaderDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
  }

  void _showJadwalDetail(core_model.Jadwal jadwal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jadwal.mataKuliahName ?? "Jadwal",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildDetailRow(Icons.calendar_today, jadwal.hari),
              _buildDetailRow(Icons.access_time,
                  "${DateFormat('HH:mm').format(jadwal.jamMulai)} - ${DateFormat('HH:mm').format(jadwal.jamSelesai)}"),
              _buildDetailRow(Icons.location_on, jadwal.ruangan ?? "-"),
              SizedBox(height: 20),
              
              // Tombol Buka Matkul
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Kita butuh object MataKuliah lengkap untuk navigasi.
                    // Ini agak tricky karena kita cuma punya ID dan Nama di sini.
                    // Untuk simplifikasi, kita tutup sheet dulu.
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Silakan buka lewat menu Mata Kuliah")),
                    );
                  },
                  child: Text("Tutup"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTugasDetail(core_model.Tugas tugas) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tugas.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                tugas.mataKuliahName ?? "Tugas",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text("Status Pengerjaan:"),
              SizedBox(height: 8),
              
              // Opsi Status Cepat
              Wrap(
                spacing: 8,
                children: ["Belum Dikerjakan", "Dalam Pengerjaan", "Selesai"]
                    .map((status) {
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
                              .updateTugas(tugas.copyWith(status: status));
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Status diupdate: $status")));
                          }
                        } catch (e) {
                           // Handle error
                        }
                      }
                    },
                  );
                }).toList(),
              ),
              
              if(tugas.note != null && tugas.note!.isNotEmpty)
                 Padding(
                   padding: const EdgeInsets.only(top: 16.0),
                   child: Text("Catatan:\n${tugas.note}"),
                 ),

              SizedBox(height: 16),
              Text("Deadline: ${DateFormat('dd MMM yyyy, HH:mm').format(tugas.dueAt)}"),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    final userName = user?.userMetadata?['full_name'] ?? "Mahasiswa";

    // Watch Data Lengkap (Hasil Join Provider)
    final asyncJadwal = ref.watch(allJadwalLengkapProvider);
    final asyncTugas = ref.watch(allTugasLengkapProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Text(
                _getHeaderDate(),
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                "Halo, $userName!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),

              // 2. Section Jadwal (dengan Filter Hari)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Jadwal Kuliah",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.calendar_today, size: 18, color: Colors.blueAccent),
                ],
              ),
              SizedBox(height: 12),
              
              // Day Chips (Scrollable)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _days.map((day) {
                    final isSelected = _selectedDay == day;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedDay = day);
                        },
                        selectedColor: Colors.blueAccent.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.blueAccent : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 12),

              // List Jadwal Horizontal
              SizedBox(
                height: 140, // Tinggi Card Jadwal
                child: asyncJadwal.when(
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text("Error memuat jadwal")),
                  data: (listJadwal) {
                    // Filter berdasarkan hari yang dipilih
                    final filtered = listJadwal
                        .where((j) => j.hari == _selectedDay)
                        .toList();
                    
                    // Sort berdasarkan jam mulai
                    filtered.sort((a, b) => a.jamMulai.compareTo(b.jamMulai));

                    if (filtered.isEmpty) {
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.weekend, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("Tidak ada jadwal $_selectedDay", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final status = item.getStatus(DateTime.now());
                        
                        Color statusColor = Colors.grey;
                        if (status == "Berlangsung") statusColor = Colors.blueAccent;
                        if (status == "Selesai") statusColor = Colors.green;

                        return GestureDetector(
                          onTap: () => _showJadwalDetail(item),
                          child: Container(
                            width: 200,
                            margin: EdgeInsets.only(right: 12),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF1E1E1E), // Dark card
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      DateFormat('HH:mm').format(item.jamMulai),
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.mataKuliahName ?? "Loading...",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 12, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(item.ruangan ?? "-", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: 24),

              // 3. Section Tugas (Deadline Tracker)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Prioritas Tugas",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Deadline Terdekat", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              SizedBox(height: 12),

              asyncTugas.when(
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, s) => Text("Error: $e"),
                data: (listTugas) {
                  // Filter: Status != Selesai
                  final activeTasks = listTugas
                      .where((t) => t.status != "Selesai")
                      .toList();
                  
                  // Sort: Deadline terdekat di atas
                  activeTasks.sort((a, b) => a.dueAt.compareTo(b.dueAt));

                  if (activeTasks.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Icon(Icons.task_alt, size: 40, color: Colors.green),
                            SizedBox(height: 8),
                            Text("Semua tugas selesai! Santai dulu.", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Agar bisa dalam SingleScrollView
                    physics: NeverScrollableScrollPhysics(), // Scroll ikut parent
                    itemCount: activeTasks.length,
                    itemBuilder: (context, index) {
                      final item = activeTasks[index];
                      final timeLeft = item.dueAt.difference(DateTime.now());
                      final isUrgent = timeLeft.inDays < 2 && !timeLeft.isNegative;
                      
                      Color cardColor = Color(0xFF1E1E1E);
                      if (isUrgent) cardColor = Colors.redAccent.withOpacity(0.1);

                      return Card(
                        color: cardColor,
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          onTap: () => _showTugasDetail(item),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent.withOpacity(0.1),
                            child: Icon(
                              _getTaskIcon(item.type), 
                              color: Colors.blueAccent, size: 20
                            ),
                          ),
                          title: Text(
                            item.title, 
                            style: TextStyle(fontWeight: FontWeight.bold, decoration: item.status == 'Selesai' ? TextDecoration.lineThrough : null)
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.mataKuliahName ?? "-"),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.timer, size: 12, color: isUrgent ? Colors.redAccent : Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    DateFormat('dd MMM, HH:mm').format(item.dueAt),
                                    style: TextStyle(
                                      color: isUrgent ? Colors.redAccent : Colors.grey, 
                                      fontSize: 12,
                                      fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal
                                    ),
                                  ),
                                  Spacer(),
                                  _StatusBadgeMini(status: item.status),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}

class _StatusBadgeMini extends StatelessWidget {
  final String status;
  const _StatusBadgeMini({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (status == "Dalam Pengerjaan") color = Colors.blueAccent;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 9)),
    );
  }
}
