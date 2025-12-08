// lib/features/mata_kuliah/add_edit_jadwal_screen.dart
// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // [WAJIB] Untuk format tanggal
import 'package:tugas_kuliyeah/core/models/jadwal.dart' as core_model;
import 'package:tugas_kuliyeah/core/providers.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
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
  // final id = const Uuid().v4(); // Tidak dipakai jika generate batch
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  late TextEditingController _ruanganC;
  
  // [BARU] Controller untuk jumlah pertemuan (Hanya mode Tambah)
  late TextEditingController _jumlahPertemuanC;
  
  // [UBAH] Dari _selectedHari (String) menjadi _selectedDate (DateTime)
  DateTime? _selectedDate;
  
  TimeOfDay? _jamMulai;
  TimeOfDay? _jamSelesai;

  // [HAPUS] List hari string tidak lagi diperlukan karena pakai DatePicker
  /*
  final List<String> _hariList = [
    "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu",
  ];
  */

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
    // Jika tambah, null dulu (nanti user pilih tanggal mulai)
    _selectedDate = _isEditing ? widget.jadwal!.tanggal : null;
    
    _jamMulai = _isEditing
        ? TimeOfDay.fromDateTime(widget.jadwal!.jamMulai)
        : null;
    _jamSelesai = _isEditing
        ? TimeOfDay.fromDateTime(widget.jadwal!.jamSelesai)
        : null;
  }

  @override
  void dispose() {
    _ruanganC.dispose();
    _jumlahPertemuanC.dispose();
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
    // Validasi input
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
    // Kita buat dummy date untuk komparasi jam
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
        // MODE EDIT: UPDATE SINGLE ROW (Pertemuan Ini Saja)
        // ==========================================
        // Ini memberi fleksibilitas: User bisa memindah 1 pertemuan ke hari lain
        
        // Kita copy object lama, update data yang berubah
        final updatedJadwal = widget.jadwal!.copyWith(
          tanggal: _selectedDate!, // Update tanggal spesifik
          jamMulai: DateTime(
            _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
            _jamMulai!.hour, _jamMulai!.minute
          ),
          jamSelesai: DateTime(
            _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
            _jamSelesai!.hour, _jamSelesai!.minute
          ),
          ruangan: _ruanganC.text,
          // batchId & pertemuanKe JANGAN DIUBAH agar tetap terlacak
        );

        await repo.updateJadwal(updatedJadwal);
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Pertemuan ke-${widget.jadwal!.pertemuanKe} diperbarui!")),
          );
        }

      } else {
        // ==========================================
        // MODE TAMBAH: GENERATE BATCH (Satu Semester)
        // ==========================================
        final jumlah = int.tryParse(_jumlahPertemuanC.text) ?? 14;
        
        await repo.generateJadwalSemester(
          mataKuliahId: widget.mataKuliahId,
          tanggalMulai: _selectedDate!,
          jumlahPertemuan: jumlah,
          jamMulai: _jamMulai!,
          jamSelesai: _jamSelesai!,
          ruangan: _ruanganC.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Berhasil membuat $jumlah jadwal pertemuan!")),
          );
        }
      }

      // [PENTING] Refresh Provider agar data baru muncul & data hantu hilang
      ref.invalidate(jadwalByMatkulProvider);
      ref.invalidate(allJadwalRawProvider); // Jika ada provider home
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
      appBar: AppBar(title: Text(_isEditing ? "Edit Jadwal" : "Buat Jadwal Semester")),
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
                  ? "Tanggal Pertemuan Ini (Bisa diubah jika ada pengganti)" 
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
                
                const SizedBox(height: 16),

                // --- BAGIAN JUMLAH PERTEMUAN (HANYA ADD MODE) ---
                if (!_isEditing) ...[
                  TextFormField(
                    controller: _jumlahPertemuanC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Jumlah Pertemuan (Minggu)",
                      helperText: "Akan men-generate jadwal mingguan otomatis",
                      prefixIcon: Icon(Icons.repeat),
                    ),
                    validator: (v) {
                      final val = int.tryParse(v ?? '');
                      if (val == null || val < 1) return "Minimal 1 pertemuan";
                      if (val > 50) return "Maksimal 50 pertemuan";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                // --- BAGIAN JAM ---
                Row(
                  children: [
                    Expanded(
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
                    const SizedBox(width: 10),
                    Expanded(
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
                
                if (!_isEditing)
                  const Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text(
                      "*Tips: Setelah generate, kamu bisa mengedit atau menghapus pertemuan spesifik (misal saat libur) melalui detail mata kuliah.",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class AddEditJadwalScreen extends ConsumerStatefulWidget { 
//   final String mataKuliahId; 
//   final core_model.Jadwal? jadwal; // Mode Edit jika tidak null 
  
//   const AddEditJadwalScreen({ 
//     super.key, 
//     required this.mataKuliahId, 
//     this.jadwal, 
//   }); 
  
//   @override ConsumerState<AddEditJadwalScreen> createState() => 
//     _AddEditJadwalScreenState(); 
// }

// class _AddEditJadwalScreenState extends ConsumerState<AddEditJadwalScreen> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isEditing = false;

//   // Controllers
//   late TextEditingController _ruanganC;
//   String? _selectedHari;
//   TimeOfDay? _jamMulai;
//   TimeOfDay? _jamSelesai;

//   final List<String> _hariList = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"];

//   @override
//   void initState() {
//     super.initState();
//     _isEditing = widget.jadwal != null;

//     _ruanganC = TextEditingController(text: _isEditing ? widget.jadwal!.ruangan : '');
//     _selectedHari = _isEditing ? widget.jadwal!.hari : null;
//     _jamMulai = _isEditing ? TimeOfDay.fromDateTime(widget.jadwal!.jamMulai) : null;
//     _jamSelesai = _isEditing ? TimeOfDay.fromDateTime(widget.jadwal!.jamSelesai) : null;
//   }
  
//   @override
//   void dispose() {
//     _ruanganC.dispose();
//     super.dispose();
//   }

//   Future<void> _pilihJam(bool isMulai) async {
//     TimeOfDay initialTime = TimeOfDay.now();

//     if (!isMulai && _jamMulai != null) {
//       // Jika user memilih JAM SELESAI dan JAM MULAI sudah ada:
//       // 1. Ubah TimeOfDay _jamMulai ke DateTime
//       final now = DateTime.now();
//       final dtMulai = DateTime(
//           now.year, now.month, now.day, _jamMulai!.hour, _jamMulai!.minute);
//       // 2. Tambahkan 1 menit sebagai default jam selesai
//       final dtSelesaiDefault = dtMulai.add(const Duration(minutes: 1));
//       // 3. Set sebagai initialTime untuk picker
//       initialTime = TimeOfDay.fromDateTime(dtSelesaiDefault);
//     }

//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: initialTime,
//     );
//     if (picked != null) {
//       setState(() {
//         if (isMulai) {
//           _jamMulai = picked;
//         } else {
//           _jamSelesai = picked;
//         }
//       });
//     }
//   }

//   Future<void> _submitForm() async {
//      // Validasi manual
//     if (_formKey.currentState!.validate() && 
//         _selectedHari != null && 
//         _jamMulai != null && 
//         _jamSelesai != null) 
//     {
//       final repository = ref.read(taskRepositoryProvider);
      
//       // Konversi TimeOfDay ke DateTime (tanggal tidak penting, hanya jam)
//       final now = DateTime.now();
//       final dtMulai = DateTime(now.year, now.month, now.day, _jamMulai!.hour, _jamMulai!.minute);
//       final dtSelesai = DateTime(now.year, now.month, now.day, _jamSelesai!.hour, _jamSelesai!.minute);

//       if (dtSelesai.isBefore(dtMulai) ||
//           dtSelesai.isAtSameMomentAs(dtMulai)) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text("Jam selesai harus setelah jam mulai.")),
//         );
//         return; // Hentikan proses submit
//       }

//       final jadwalBaru = core_model.Jadwal(
//         id: _isEditing ? widget.jadwal!.id : Random().nextInt(99999).toString(),
//         mataKuliahId: widget.mataKuliahId,
//         hari: _selectedHari!,
//         jamMulai: dtMulai,
//         jamSelesai: dtSelesai,
//         ruangan: _ruanganC.text,
//       );

//       try {
//         if (_isEditing) {
//           await repository.updateJadwal(jadwalBaru);
//         } else {
//           await repository.addJadwal(jadwalBaru);
//         }

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Jadwal Disimpan!")));
//           Navigator.pop(context);
//         }
//       } catch (e) {
//          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
//       }

//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Harap lengkapi semua data jadwal.")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_isEditing ? "Edit Jadwal" : "Tambah Jadwal"),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // --- Pilih Hari ---
//               DropdownButtonFormField<String>(
//                 value: _selectedHari,
//                 hint: Text("Pilih Hari"),
//                 isExpanded: true,
//                 items: _hariList.map((String hari) {
//                   return DropdownMenuItem<String>(
//                     value: hari,
//                     child: Text(hari),
//                   );
//                 }).toList(),
//                 onChanged: (newValue) {
//                   setState(() {
//                     _selectedHari = newValue;
//                   });
//                 },
//                 validator: (value) => value == null ? 'Hari wajib dipilih' : null,
//               ),
//               SizedBox(height: 16),
              
//               // --- Pilih Jam ---
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       icon: Icon(Icons.access_time),
//                       label: Text(_jamMulai == null ? "Jam Mulai" : _jamMulai!.format(context)),
//                       onPressed: () => _pilihJam(true),
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       icon: Icon(Icons.access_time_filled),
//                       label: Text(_jamSelesai == null ? "Jam Selesai" : _jamSelesai!.format(context)),
//                       onPressed: () => _pilihJam(false),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),

//               // --- Input Ruangan ---
//               TextFormField(
//                 controller: _ruanganC,
//                 decoration: InputDecoration(labelText: "Lokasi/Ruangan"),
//                 validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
//               ),
//               SizedBox(height: 30),

//               // --- Tombol Simpan ---
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 child: Text("Simpan Jadwal"),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(double.infinity, 50) // Lebar penuh
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }