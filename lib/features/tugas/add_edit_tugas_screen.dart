// // lib/features/tugas/add_edit_tugas_screen.dart
// import 'dart:math';
// import 'package:file_picker/file_picker.dart'; // Import Library
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:tugas_kuliyeah/core/models/tugas.dart' as core_model;
// import 'package:tugas_kuliyeah/core/providers.dart';
// import 'package:uuid/uuid.dart';

// class AddEditTugasScreen extends ConsumerStatefulWidget {
//   final String mataKuliahId;
//   final core_model.Tugas? tugas; // Mode Edit jika tidak null

//   const AddEditTugasScreen({super.key, required this.mataKuliahId, this.tugas});

//   @override
//   ConsumerState<AddEditTugasScreen> createState() => _AddEditTugasScreenState();
// }

// class _AddEditTugasScreenState extends ConsumerState<AddEditTugasScreen> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isEditing = false;

//   // Controllers
//   late TextEditingController _deskripsiC;
//   String? _selectedJenis;
//   DateTime? _tenggatWaktu;

//   // --- BAGIAN EKA: Variabel Path File ---
//   String? _attachmentPath;
//   // -------------------------------------

//   final List<String> _jenisList = ["Tugas", "Kuis", "UTS", "UAS"];

//   @override
//   void initState() {
//     super.initState();
//     _isEditing = widget.tugas != null;

//     _deskripsiC = TextEditingController(
//       text: _isEditing ? widget.tugas!.note : '',
//     );
//     _selectedJenis = _isEditing ? widget.tugas!.type : null;
//     _tenggatWaktu = _isEditing ? widget.tugas!.dueAt : null;

//     // Isi variabel path jika sedang edit data lama
//     _attachmentPath = _isEditing ? widget.tugas!.attachmentPath : null;
//   }

//   @override
//   void dispose() {
//     _deskripsiC.dispose();
//     super.dispose();
//   }

//   Future<void> _pilihTenggat() async {
//     // 1. Pilih Tanggal
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: _tenggatWaktu ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );

//     if (pickedDate == null) return; // User batal

//     // 2. Pilih Jam
//     final TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.fromDateTime(_tenggatWaktu ?? DateTime.now()),
//     );

//     if (pickedTime == null) return; // User batal

//     // 3. Gabungkan
//     setState(() {
//       _tenggatWaktu = DateTime(
//         pickedDate.year,
//         pickedDate.month,
//         pickedDate.day,
//         pickedTime.hour,
//         pickedTime.minute,
//       );
//     });
//   }

//   // --- BAGIAN EKA: Fungsi Pilih File (Diperbarui) ---
//   Future<void> _pilihFile() async {
//     // Membuka File Explorer
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
//     );

//     if (result != null) {
//       // Cek apakah path tersedia (Di Web, path seringkali null)
//       if (result.files.single.path != null) {
//         setState(() {
//           _attachmentPath = result.files.single.path;
//         });
//       } else {
//         // Tampilkan peringatan jika di Web path-nya tidak terbaca
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               backgroundColor: Colors.orange,
//               content: Text(
//                 "Di Web, path file tidak bisa dibaca langsung.\nMohon coba di Android Emulator.",
//               ),
//               duration: Duration(seconds: 4),
//             ),
//           );
//         }
//       }
//     }
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate() ||
//         _selectedJenis == null ||
//         _tenggatWaktu == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Harap lengkapi semua data tugas.")),
//       );
//       return;
//     }

//     final repo = ref.read(taskRepositoryProvider);

//     // --- Bikin ID UUID kalau create ---
//     final tugasId = _isEditing ? widget.tugas!.id : const Uuid().v4();

//     final tugasBaru = core_model.Tugas(
//       id: tugasId,
//       mataKuliahId: widget.mataKuliahId,
//       jenis: _selectedJenis!,
//       deskripsi: _deskripsiC.text,
//       tenggatWaktu: _tenggatWaktu!,
//       attachmentPath: _attachmentPath,
//       createdAt: _isEditing
//           ? widget.tugas!.createdAt
//           : DateTime.now(), // WAJIB karena NOT NULL
//     );

//     try {
//       if (_isEditing) {
//         await repo.updateTugas(tugasBaru);
//       } else {
//         await repo.insertTugas(tugasBaru);
//       }

//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Tugas disimpan!")));
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(_isEditing ? "Edit Tugas" : "Tambah Tugas")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // --- Pilih Jenis ---
//               DropdownButtonFormField<String>(
//                 value: _selectedJenis,
//                 hint: Text("Pilih Jenis"),
//                 isExpanded: true,
//                 items: _jenisList.map((String jenis) {
//                   return DropdownMenuItem<String>(
//                     value: jenis,
//                     child: Text(jenis),
//                   );
//                 }).toList(),
//                 onChanged: (newValue) {
//                   setState(() {
//                     _selectedJenis = newValue;
//                   });
//                 },
//                 validator: (value) =>
//                     value == null ? 'Jenis wajib dipilih' : null,
//               ),
//               SizedBox(height: 16),

//               // --- Input Deskripsi ---
//               TextFormField(
//                 controller: _deskripsiC,
//                 decoration: InputDecoration(labelText: "Deskripsi"),
//                 validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
//               ),
//               SizedBox(height: 16),

//               // --- Pilih Tenggat Waktu ---
//               ElevatedButton.icon(
//                 icon: Icon(Icons.calendar_today),
//                 label: Text(
//                   _tenggatWaktu == null
//                       ? "Pilih Tenggat Waktu"
//                       : DateFormat('dd MMM yyyy, HH:mm').format(_tenggatWaktu!),
//                 ),
//                 onPressed: _pilihTenggat,
//               ),
//               SizedBox(height: 16),

//               // --- BAGIAN EKA: UI Pilih File ---
//               Text(
//                 "Lampiran (PDF/Gambar):",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Card(
//                 child: ListTile(
//                   leading: Icon(Icons.attach_file),
//                   title: Text(
//                     _attachmentPath != null
//                         ? _attachmentPath!
//                               .split('/')
//                               .last // Ambil nama filenya saja
//                         : "Belum ada file dipilih",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   trailing: IconButton(
//                     icon: Icon(Icons.folder_open),
//                     onPressed: _pilihFile,
//                   ),
//                 ),
//               ),
//               if (_attachmentPath != null)
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       _attachmentPath = null; // Hapus file
//                     });
//                   },
//                   child: Text(
//                     "Hapus Lampiran",
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ),

//               SizedBox(height: 30),

//               // --- Tombol Simpan ---
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 child: Text("Simpan Tugas"),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(double.infinity, 50), // Lebar penuh
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tugas_kuliyeah/core/models/tugas.dart' as core_model;
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:uuid/uuid.dart';

class AddEditTugasScreen extends ConsumerStatefulWidget {
  final String mataKuliahId;
  final core_model.Tugas? tugas;

  const AddEditTugasScreen({super.key, required this.mataKuliahId, this.tugas});

  @override
  ConsumerState<AddEditTugasScreen> createState() => _AddEditTugasScreenState();
}

class _AddEditTugasScreenState extends ConsumerState<AddEditTugasScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEditing;

  late TextEditingController _titleC;
  late TextEditingController _noteC;

  String? _selectedJenis;
  DateTime? _dueAt;
  String? _attachmentPath;

  final List<String> _jenisList = ["Tugas", "Kuis", "UTS", "UAS"];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.tugas != null;

    _titleC = TextEditingController(
      text: _isEditing ? widget.tugas!.title : '',
    );

    _noteC = TextEditingController(text: _isEditing ? widget.tugas!.note : '');

    _selectedJenis = _isEditing ? widget.tugas!.type : null;
    _dueAt = _isEditing ? widget.tugas!.dueAt : null;
    _attachmentPath = _isEditing ? widget.tugas!.attachmentPath : null;
  }

  @override
  void dispose() {
    _titleC.dispose();
    _noteC.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueAt ?? DateTime.now()),
    );

    if (time == null) return;

    setState(() {
      _dueAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachmentPath = result.files.single.path;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _selectedJenis == null ||
        _dueAt == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Harap lengkapi semua data")));
      return;
    }

    final user = ref.read(userProvider);

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User tidak ditemukan")));
      return;
    }

    final repo = ref.read(taskRepositoryProvider);

    final id = _isEditing ? widget.tugas!.id : const Uuid().v4();

    final tugas = core_model.Tugas(
      id: id,
      ownerId: user.id,
      title: _titleC.text,
      type: _selectedJenis!,
      note: _noteC.text.isNotEmpty ? _noteC.text : null,
      dueAt: _dueAt!,
      createdAt: _isEditing ? widget.tugas!.createdAt : DateTime.now(),
      mataKuliahId: widget.mataKuliahId,
      attachmentPath: _attachmentPath,
    );

    try {
      if (_isEditing) {
        await repo.updateTugas(tugas);
      } else {
        await repo.insertTugas(tugas);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Tugas disimpan")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? "Edit Tugas" : "Tambah Tugas")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleC,
                decoration: InputDecoration(labelText: "Judul Tugas"),
                validator: (v) => v!.isEmpty ? "Judul wajib diisi" : null,
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedJenis,
                hint: Text("Pilih Jenis"),
                items: _jenisList
                    .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedJenis = v),
                validator: (v) => v == null ? "Jenis wajib dipilih" : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _noteC,
                decoration: InputDecoration(labelText: "Deskripsi"),
              ),
              SizedBox(height: 16),

              ElevatedButton.icon(
                icon: Icon(Icons.calendar_today),
                label: Text(
                  _dueAt == null
                      ? "Pilih Tenggat Waktu"
                      : DateFormat("dd MMM yyyy, HH:mm").format(_dueAt!),
                ),
                onPressed: _pickDeadline,
              ),
              SizedBox(height: 16),

              Text("Lampiran:", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),

              Card(
                child: ListTile(
                  leading: Icon(Icons.attach_file),
                  title: Text(
                    _attachmentPath != null
                        ? _attachmentPath!.split("/").last
                        : "Belum ada file",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.folder_open),
                    onPressed: _pickFile,
                  ),
                ),
              ),

              if (_attachmentPath != null)
                TextButton(
                  onPressed: () => setState(() => _attachmentPath = null),
                  child: Text(
                    "Hapus Lampiran",
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              SizedBox(height: 30),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                ),
                child: Text("Simpan Tugas"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
