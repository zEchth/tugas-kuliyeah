// lib/features/mata_kuliah/add_edit_jadwal_screen.dart
// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // [WAJIB] Untuk format tanggal
import 'package:tugas_kuliyeah/core/models/jadwal.dart' as core_model;
import 'package:tugas_kuliyeah/core/providers.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:uuid/uuid.dart';
// import 'package:intl/intl.dart'; // Untuk format TimeOfDay

class AddEditJadwalScreen extends ConsumerStatefulWidget {
  final String mataKuliahId;
  final core_model.Jadwal? jadwal;

  const AddEditJadwalScreen({
    super.key,
    required this.mataKuliahId,
    this.jadwal,
  });

  @override
  ConsumerState<AddEditJadwalScreen> createState() =>
      _AddEditJadwalScreenState();
}

class _AddEditJadwalScreenState extends ConsumerState<AddEditJadwalScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  late TextEditingController _ruanganC;
  
  // [BARU] Controller untuk jumlah pertemuan (Hanya mode Tambah)
  late TextEditingController _jumlahPertemuanC;
  
  // [BARU] Controller untuk Penamaan
  late TextEditingController _customTitleC; // Untuk judul "UTS" atau "Pertemuan ke-"
  late TextEditingController _startNumberC; // Untuk angka mulai (2, 36, dll)
  
  // [BARU] Variabel Zona Waktu
  String _selectedZona = 'WITA';
  final List<String> _zonaList = ['WIB', 'WITA', 'WIT'];

  // State Mode Penamaan
  // true = "Pertemuan ke-{N}", "Pertemuan ke-{N+1}"
  // false = "UTS", "UTS" (Custom text statis)
  bool _useAutoTitle = true; 

  DateTime? _selectedDate;
  TimeOfDay? _jamMulai;
  TimeOfDay? _jamSelesai;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.jadwal != null;

    _ruanganC = TextEditingController(
      text: _isEditing ? widget.jadwal!.ruangan : '',
    );
    
    // Default 16 pertemuan untuk semester normal
    _jumlahPertemuanC = TextEditingController(text: '16'); 

    // Jika edit, ambil tanggal spesifik dari jadwal tersebut
    _selectedDate = _isEditing ? widget.jadwal!.tanggal : null;
    
    _jamMulai = _isEditing
        ? TimeOfDay.fromDateTime(widget.jadwal!.jamMulai)
        : null;
    _jamSelesai = _isEditing
        ? TimeOfDay.fromDateTime(widget.jadwal!.jamSelesai)
        : null;
        
    // [BARU] Inisialisasi Judul & Angka & Zona
    if (_isEditing) {
      // Jika edit single, anggap selalu Custom agar user bebas ubah teksnya
      _useAutoTitle = false;
      _customTitleC = TextEditingController(text: widget.jadwal!.judul);
      _startNumberC = TextEditingController(); // Tidak dipakai di mode edit single
      _selectedZona = widget.jadwal!.zonaWaktu; // [BARU] Load zona waktu
    } else {
      // Mode Add Batch
      _useAutoTitle = true;
      _customTitleC = TextEditingController(text: "Pertemuan ke-");
      _startNumberC = TextEditingController(text: "1"); // Default mulai dari 1
    }
  }

  @override
  void dispose() {
    _ruanganC.dispose();
    _jumlahPertemuanC.dispose();
    _customTitleC.dispose();
    _startNumberC.dispose();
    super.dispose();
  }

  // [BARU] Fungsi pilih Tanggal (DatePicker)
  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pilihJam(bool isMulai) async {
    final initial = TimeOfDay.now();

    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (isMulai) {
          _jamMulai = picked;
        } else {
          _jamSelesai = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    // Validasi input dasar
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _jamMulai == null ||
        _jamSelesai == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Harap lengkapi semua data.")));
      return;
    }

    // Validasi Logika Jam
    final dtMulai = DateTime(2000, 1, 1, _jamMulai!.hour, _jamMulai!.minute);
    final dtSelesai = DateTime(2000, 1, 1, _jamSelesai!.hour, _jamSelesai!.minute);

    if (dtSelesai.isBefore(dtMulai)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Jam selesai harus setelah jam mulai.")),
      );
      return;
    }

    final repo = ref.read(taskRepositoryProvider);
    final user = ref.read(userProvider);
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User tidak ditemukan")),
      );
      return;
    }

    try {
      if (_isEditing) {
        // ==========================================
        // MODE EDIT: UPDATE SINGLE ROW (Judul String Bebas)
        // ==========================================
        
        final updatedJadwal = widget.jadwal!.copyWith(
          tanggal: _selectedDate!, 
          jamMulai: DateTime(
            _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
            _jamMulai!.hour, _jamMulai!.minute
          ),
          jamSelesai: DateTime(
            _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
            _jamSelesai!.hour, _jamSelesai!.minute
          ),
          ruangan: _ruanganC.text,
          judul: _customTitleC.text, // Simpan judul apa adanya dari input
          zonaWaktu: _selectedZona, // [BARU] Update zona waktu
        );

        await repo.updateJadwal(updatedJadwal);
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Jadwal diperbarui!")),
          );
        }

      } else {
        // ==========================================
        // MODE TAMBAH: GENERATE BATCH (Controlled Naming)
        // ==========================================
        final jumlah = int.tryParse(_jumlahPertemuanC.text) ?? 14;
        final startNum = int.tryParse(_startNumberC.text) ?? 1;
        
        await repo.generateJadwalSemester(
          mataKuliahId: widget.mataKuliahId,
          tanggalMulai: _selectedDate!,
          jumlahPertemuan: jumlah,
          jamMulai: _jamMulai!,
          jamSelesai: _jamSelesai!,
          ruangan: _ruanganC.text,
          
          // Parameter Kontrol
          useAutoTitle: _useAutoTitle,
          customTitlePrefix: _customTitleC.text, // "Pertemuan ke-" atau "UTS"
          startNumber: startNum, // Angka mulai yg ditentukan user
          
          // [BARU] Zona Waktu
          zonaWaktu: _selectedZona,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Berhasil membuat $jumlah jadwal pertemuan!")),
          );
        }
      }

      // [PENTING] Refresh Provider
      ref.invalidate(jadwalByMatkulProvider);
      ref.invalidate(allJadwalRawProvider);
      ref.read(globalRefreshProvider.notifier).state++;

      if (mounted) {
        Navigator.pop(context);
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? "Edit Jadwal" : "Buat Jadwal")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BAGIAN TANGGAL ---
                Text(
                  _isEditing 
                  ? "Tanggal Pertemuan Ini" 
                  : "Tanggal Pertemuan Pertama",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pilihTanggal,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.blueAccent),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate == null
                              ? "Pilih Tanggal Mulai"
                              : DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate!),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ===============================================
                //       BAGIAN PENAMAAN & JUMLAH (LOGIKA BARU)
                // ===============================================
                
                if (!_isEditing) ...[
                  const Text("Pengaturan Penamaan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  
                  Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: const Color(0xFF1E1E1E),
                       borderRadius: BorderRadius.circular(12),
                       border: Border.all(color: Colors.white10),
                     ),
                     child: Column(
                       children: [
                         // Opsi 1: Format Seri
                         RadioListTile<bool>(
                           title: const Text("Format Seri"),
                           subtitle: Text('Contoh: "${_customTitleC.text}1", "${_customTitleC.text}2"...'),
                           value: true,
                           groupValue: _useAutoTitle,
                           activeColor: Colors.blueAccent,
                           onChanged: (val) {
                             setState(() {
                               _useAutoTitle = val!;
                               _customTitleC.text = "Pertemuan ke-"; // Reset default
                             });
                           },
                         ),
                         
                         // Opsi 2: Format Kustom
                         RadioListTile<bool>(
                           title: const Text("Format Kustom (Statis)"),
                           subtitle: const Text('Contoh: "Responsi", "Ujian Praktik" (Semua jadwal bernama sama)'),
                           value: false,
                           groupValue: _useAutoTitle,
                           activeColor: Colors.blueAccent,
                           onChanged: (val) {
                             setState(() {
                               _useAutoTitle = val!;
                               _customTitleC.clear(); // Clear agar user isi sendiri
                             });
                           },
                         ),
                         
                         const Divider(color: Colors.white24),
                         const SizedBox(height: 8),

                         // Field 1: Input Judul / Prefix
                         TextFormField(
                            controller: _customTitleC,
                            decoration: InputDecoration(
                              labelText: _useAutoTitle ? "Awalan Judul" : "Judul Jadwal",
                              hintText: _useAutoTitle ? "Pertemuan ke-" : "Misal: Responsi",
                              prefixIcon: const Icon(Icons.title),
                              filled: true,
                              fillColor: Colors.black12,
                            ),
                            onChanged: (_) => setState((){}), // Refresh UI preview
                            validator: (v) => v!.isEmpty ? "Judul tidak boleh kosong" : null,
                         ),
                         
                         // Field 2: Input Angka Mulai (Hanya jika Format Seri)
                         if (_useAutoTitle) ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _startNumberC,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Mulai dari Nomor Berapa?",
                                helperText: "Tentukan sendiri nomor awalnya (misal 1, 36, atau 5)",
                                prefixIcon: Icon(Icons.format_list_numbered),
                                filled: true,
                                fillColor: Colors.black12,
                              ),
                            ),
                         ],
                       ],
                     ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Jumlah Pertemuan
                  TextFormField(
                    controller: _jumlahPertemuanC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Jumlah Pertemuan (Minggu)",
                      helperText: "Akan men-generate jadwal mingguan otomatis",
                      prefixIcon: Icon(Icons.repeat),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final val = int.tryParse(v ?? '');
                      if (val == null || val < 1) return "Minimal 1 pertemuan";
                      if (val > 50) return "Maksimal 50 pertemuan";
                      return null;
                    },
                  ),
                ] else ...[
                   // Jika Edit Mode: Hanya Text Field Judul Biasa
                   TextFormField(
                      controller: _customTitleC,
                      decoration: const InputDecoration(
                        labelText: "Judul Jadwal",
                        prefixIcon: Icon(Icons.edit),
                      ),
                   ),
                ],

                const SizedBox(height: 24),
                
                // --- BAGIAN JAM & ZONA ---
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _pilihJam(true),
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          _jamMulai == null
                              ? "Jam Mulai"
                              : _jamMulai!.format(context),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _pilihJam(false),
                        icon: const Icon(Icons.access_time_filled),
                        label: Text(
                          _jamSelesai == null
                              ? "Jam Selesai"
                              : _jamSelesai!.format(context),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // [BARU] DROPDOWN ZONA WAKTU
                DropdownButtonFormField<String>(
                  value: _selectedZona,
                  decoration: const InputDecoration(
                    labelText: "Zona Waktu",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.public),
                  ),
                  items: _zonaList.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                  onChanged: (val) {
                     if (val != null) setState(() => _selectedZona = val);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // --- BAGIAN RUANGAN ---
                TextFormField(
                  controller: _ruanganC,
                  decoration: const InputDecoration(
                    labelText: "Ruangan",
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                
                const SizedBox(height: 30),
                
                // --- TOMBOL SIMPAN ---
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_isEditing ? "Simpan Perubahan" : "Generate Jadwal"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}