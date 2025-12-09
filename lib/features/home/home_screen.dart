import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:tugas_kuliyeah/core/models/tugas.dart' as core_model;
import 'package:tugas_kuliyeah/core/models/jadwal.dart' as core_model;
// import 'package:tugas_kuliyeah/features/mata_kuliah/mata_kuliah_detail_screen.dart'; // (Tetap mempertahankan import jika dibutuhkan di masa depan)

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Default format
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _selectedDay = _focusedDay;
  }

  // [PERBAIKAN LOGIKA] Mengambil event (Jadwal & Tugas) untuk tanggal tertentu
  List<dynamic> _getEventsForDay(
    DateTime day,
    List<core_model.Jadwal> allJadwal,
    List<core_model.Tugas> allTugas,
  ) {
    List<dynamic> events = [];

    // 1. Cek Jadwal Kuliah (Sekarang berdasarkan TANGGAL SPESIFIK)
    final jadwalHariIni = allJadwal.where((j) {
      return isSameDay(j.tanggal, day); 
    }).toList();
    
    events.addAll(jadwalHariIni);

    // 2. Cek Tugas (One-time)
    final tugasHariIni = allTugas.where((t) {
      return isSameDay(t.dueAt, day);
    }).toList();
    events.addAll(tugasHariIni);

    return events;
  }

  // --- LOGIKA BARU: SIKLUS 3 MODE VIEW ---
  void _cycleCalendarFormat() {
    setState(() {
      if (_calendarFormat == CalendarFormat.week) {
        _calendarFormat = CalendarFormat.twoWeeks;
      } else if (_calendarFormat == CalendarFormat.twoWeeks) {
        _calendarFormat = CalendarFormat.month;
      } else {
        _calendarFormat = CalendarFormat.week;
      }
    });
  }

  // Helper untuk mendapatkan label text berdasarkan mode saat ini
  String _getFormatLabel() {
    switch (_calendarFormat) {
      case CalendarFormat.week:
        return "Mingguan";
      case CalendarFormat.twoWeeks:
        return "2 Minggu";
      case CalendarFormat.month:
        return "Bulanan";
      default:
        return "Mingguan";
    }
  }

  // BottomSheet Detail Jadwal
  void _showJadwalDetail(core_model.Jadwal jadwal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      jadwal.mataKuliahName ?? "Jadwal Kuliah",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _StatusBadge(status: jadwal.statusPertemuan),
                ],
              ),
              const SizedBox(height: 8),
              
              // [UPDATE] Info Judul Jadwal (Bukan lagi angka pertemuan ke-X yang kaku)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  jadwal.judul, // [FIX] Gunakan field judul
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),

              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.calendar_today, 
                DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(jadwal.tanggal)
              ),
              _buildDetailRow(Icons.access_time,
                  "${DateFormat('HH:mm').format(jadwal.jamMulai)} - ${DateFormat('HH:mm').format(jadwal.jamSelesai)}"),
              _buildDetailRow(Icons.location_on, jadwal.ruangan ?? "-"),
              
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tutup"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // BottomSheet Detail Tugas
  void _showTugasDetail(core_model.Tugas tugas) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tugas.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                tugas.mataKuliahName ?? "Tugas",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text("Status Pengerjaan:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

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

                          // Force refresh home screen data
                          ref.refresh(allTugasRawProvider);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Status diupdate: $status")));
                          }
                        } catch (e) {
                           ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gagal update: $e")));
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

              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.timer, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text("Deadline: ${DateFormat('dd MMM yyyy, HH:mm').format(tugas.dueAt)}"),
                ],
              ),
            ],
          ),
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
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    final userName = user?.userMetadata?['full_name'] ?? "Mahasiswa";

    final asyncJadwal = ref.watch(allJadwalLengkapProvider);
    final asyncTugas = ref.watch(allTugasLengkapProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      "Halo, $userName!",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // BAGIAN KALENDER
              asyncJadwal.when(
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                )),
                error: (e, s) => Center(child: Text("Gagal memuat kalender: $e")),
                data: (listJadwal) {
                  return asyncTugas.when(
                    loading: () => const SizedBox(),
                    error: (e, s) => const SizedBox(),
                    data: (listTugas) {
                      return Column(
                        children: [
                          // Custom Header untuk "View Mode" yang lebih intuitif
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Bulan & Tahun
                                Text(
                                  DateFormat('MMMM yyyy', 'id_ID').format(_focusedDay),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                                ),
                                // Tombol View Mode
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _cycleCalendarFormat,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.blueAccent.withOpacity(0.3)
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            _getFormatLabel(),
                                            style: const TextStyle(
                                              fontSize: 12, 
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueAccent
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            _calendarFormat == CalendarFormat.month 
                                              ? Icons.unfold_less 
                                              : Icons.unfold_more,
                                            size: 16,
                                            color: Colors.blueAccent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Widget Kalender
                          const SizedBox(height: 8),
                          _buildCalendar(listJadwal, listTugas),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              // LIST 1: AGENDA HARI TERPILIH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Agenda ${_selectedDay != null ? DateFormat('d MMMM', 'id_ID').format(_selectedDay!) : 'Hari Ini'}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              _buildAgendaList(asyncJadwal, asyncTugas),

              const SizedBox(height: 24),

              // LIST 2: TUGAS TERDEKAT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.access_alarm, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Tugas Terdekat",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildUpcomingTasksList(asyncTugas),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Kalender
  Widget _buildCalendar(List<core_model.Jadwal> jadwalList, List<core_model.Tugas> tugasList) {
    return TableCalendar(
      locale: 'id_ID',
      firstDay: DateTime.utc(2020, 1, 1), 
      lastDay: DateTime.utc(2035, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      
      headerVisible: false, 

      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
        weekendStyle: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      
      calendarStyle: CalendarStyle(
        defaultTextStyle: const TextStyle(color: Colors.white),
        weekendTextStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        
        selectedDecoration: const BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
        
        todayDecoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blueAccent, width: 1.5),
        ),
        todayTextStyle: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
        
        outsideDaysVisible: false, 
      ),

      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() => _calendarFormat = format);
        }
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },

      eventLoader: (day) => _getEventsForDay(day, jadwalList, tugasList),

      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;

          bool hasTugas = events.any((e) => e is core_model.Tugas);
          bool hasJadwal = events.any((e) => e is core_model.Jadwal);

          return Positioned(
            bottom: 4, 
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasJadwal)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    width: 4, height: 4,
                    decoration: const BoxDecoration(color: Colors.lightBlueAccent, shape: BoxShape.circle),
                  ),
                if (hasTugas)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    width: 4, height: 4,
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget List Agenda
  Widget _buildAgendaList(
    AsyncValue<List<core_model.Jadwal>> asyncJadwal,
    AsyncValue<List<core_model.Tugas>> asyncTugas
  ) {
    if (asyncJadwal.isLoading || asyncTugas.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final listJadwal = asyncJadwal.value ?? [];
    final listTugas = asyncTugas.value ?? [];

    if (_selectedDay == null) return const SizedBox();

    final events = _getEventsForDay(_selectedDay!, listJadwal, listTugas);

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 40, color: Colors.grey.withOpacity(0.3)),
              const SizedBox(height: 8),
              Text(
                "Tidak ada agenda.",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    events.sort((a, b) {
      DateTime timeA;
      if (a is core_model.Jadwal) {
        timeA = DateTime(
          a.tanggal.year, a.tanggal.month, a.tanggal.day, 
          a.jamMulai.hour, a.jamMulai.minute
        );
      } else {
        timeA = (a as core_model.Tugas).dueAt;
      }

      DateTime timeB;
      if (b is core_model.Jadwal) {
        timeB = DateTime(
          b.tanggal.year, b.tanggal.month, b.tanggal.day, 
          b.jamMulai.hour, b.jamMulai.minute
        );
      } else {
        timeB = (b as core_model.Tugas).dueAt;
      }

      return timeA.compareTo(timeB);
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final item = events[index];
        if (item is core_model.Jadwal) return _buildJadwalCard(item);
        if (item is core_model.Tugas) return _buildTugasCard(item);
        return const SizedBox();
      },
    );
  }

  // Widget List Tugas Terdekat
  Widget _buildUpcomingTasksList(AsyncValue<List<core_model.Tugas>> asyncTugas) {
    if (asyncTugas.isLoading) return const Center(child: CircularProgressIndicator());
    if (asyncTugas.hasError) return Text("Error: ${asyncTugas.error}");

    final listTugas = asyncTugas.value ?? [];
    final now = DateTime.now();

    final upcomingTasks = listTugas.where((t) {
      return t.status != 'Selesai' && t.dueAt.isAfter(now);
    }).toList();

    upcomingTasks.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    final topTasks = upcomingTasks.take(5).toList();

    if (topTasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.task_alt, size: 40, color: Colors.green.withOpacity(0.5)),
              const SizedBox(height: 8),
              const Text(
                "Tidak ada tugas mendesak. Kerja bagus!",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: topTasks.length,
      itemBuilder: (context, index) {
        return _buildTugasCard(topTasks[index]);
      },
    );
  }

  // --- Helper UI Components ---

  Widget _buildJadwalCard(core_model.Jadwal item) {
    final status = item.getStatus(DateTime.now());
    
    return GestureDetector(
      onTap: () => _showJadwalDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('HH:mm').format(item.jamMulai),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 2),
                  const Text("Mulai", style: TextStyle(fontSize: 9, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.mataKuliahName ?? "Jadwal",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(item.ruangan ?? "-", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 10),
                      _StatusBadgeMini(status: status),
                    ],
                  ),
                  // [BARU] Indikator Judul (Fleksibel)
                  const SizedBox(height: 4),
                  Text(
                    item.judul, // [FIX] Tampilkan judul, bukan pertemuanKe
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTugasCard(core_model.Tugas item) {
    final isUrgent = item.dueAt.difference(DateTime.now()).inDays < 2;
    return GestureDetector(
      onTap: () => _showTugasDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUrgent ? Colors.redAccent.withOpacity(0.1) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isUrgent ? Colors.redAccent.withOpacity(0.3) : Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.redAccent.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('HH:mm').format(item.dueAt),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUrgent ? Colors.redAccent : Colors.white
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(DateFormat('d MMM').format(item.dueAt), style: const TextStyle(fontSize: 9, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: item.status == 'Selesai' ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    item.mataKuliahName ?? "Tugas",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(_getTaskIcon(item.type), color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  IconData _getTaskIcon(String type) {
    switch (type.toLowerCase()) {
      case 'kuis': return Icons.quiz;
      case 'uts': return Icons.history_edu;
      case 'uas': return Icons.school;
      default: return Icons.assignment;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = const Color(0xFFE0C9A6);
    if (status == "Berlangsung") color = Colors.blueAccent;
    if (status == "Selesai") color = Colors.green;
    if (status == "Dibatalkan" || status == "Libur") color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatusBadgeMini extends StatelessWidget {
  final String status;
  const _StatusBadgeMini({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = const Color(0xFFE0C9A6);
    if (status == "Berlangsung") color = Colors.blueAccent;
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