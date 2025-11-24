// lib/features/mata_kuliah/add_edit_jadwal_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kuliyeah/core/models/jadwal.dart' as core_model;
import 'package:tugas_kuliyeah/core/providers.dart';
// import 'package:intl/intl.dart'; // Untuk format TimeOfDay

class AddEditJadwalScreen extends ConsumerStatefulWidget {
  final String mataKuliahId;
  final core_model.Jadwal? jadwal; // Mode Edit jika tidak null

  const AddEditJadwalScreen({
    super.key,
    required this.mataKuliahId,
    this.jadwal,
  });

  @override
  ConsumerState<AddEditJadwalScreen> createState() => _AddEditJadwalScreenState();
}

class _AddEditJadwalScreenState extends ConsumerState<AddEditJadwalScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  // Controllers
  late TextEditingController _ruanganC;
  String? _selectedHari;
  TimeOfDay? _jamMulai;
  TimeOfDay? _jamSelesai;

  final List<String> _hariList = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.jadwal != null;

    _ruanganC = TextEditingController(text: _isEditing ? widget.jadwal!.ruangan : '');
    _selectedHari = _isEditing ? widget.jadwal!.hari : null;
    _jamMulai = _isEditing ? TimeOfDay.fromDateTime(widget.jadwal!.jamMulai) : null;
    _jamSelesai = _isEditing ? TimeOfDay.fromDateTime(widget.jadwal!.jamSelesai) : null;
  }
  
  @override
  void dispose() {
    _ruanganC.dispose();
    super.dispose();
  }

  Future<void> _pilihJam(bool isMulai) async {
    TimeOfDay initialTime = TimeOfDay.now();

    if (!isMulai && _jamMulai != null) {
      // Jika user memilih JAM SELESAI dan JAM MULAI sudah ada:
      // 1. Ubah TimeOfDay _jamMulai ke DateTime
      final now = DateTime.now();
      final dtMulai = DateTime(
          now.year, now.month, now.day, _jamMulai!.hour, _jamMulai!.minute);
      // 2. Tambahkan 1 menit sebagai default jam selesai
      final dtSelesaiDefault = dtMulai.add(const Duration(minutes: 1));
      // 3. Set sebagai initialTime untuk picker
      initialTime = TimeOfDay.fromDateTime(dtSelesaiDefault);
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
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
     // Validasi manual
    if (_formKey.currentState!.validate() && 
        _selectedHari != null && 
        _jamMulai != null && 
        _jamSelesai != null) 
    {
      final repository = ref.read(taskRepositoryProvider);
      
      // Konversi TimeOfDay ke DateTime (tanggal tidak penting, hanya jam)
      final now = DateTime.now();
      final dtMulai = DateTime(now.year, now.month, now.day, _jamMulai!.hour, _jamMulai!.minute);
      final dtSelesai = DateTime(now.year, now.month, now.day, _jamSelesai!.hour, _jamSelesai!.minute);

      if (dtSelesai.isBefore(dtMulai) ||
          dtSelesai.isAtSameMomentAs(dtMulai)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Jam selesai harus setelah jam mulai.")),
        );
        return; // Hentikan proses submit
      }

      final jadwalBaru = core_model.Jadwal(
        id: _isEditing ? widget.jadwal!.id : Random().nextInt(99999).toString(),
        mataKuliahId: widget.mataKuliahId,
        hari: _selectedHari!,
        jamMulai: dtMulai,
        jamSelesai: dtSelesai,
        ruangan: _ruanganC.text,
      );

      try {
        if (_isEditing) {
          await repository.updateJadwal(jadwalBaru);
        } else {
          await repository.addJadwal(jadwalBaru);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Jadwal Disimpan!")));
          Navigator.pop(context);
        }
      } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Harap lengkapi semua data jadwal.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Jadwal" : "Tambah Jadwal"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Pilih Hari ---
              DropdownButtonFormField<String>(
                value: _selectedHari,
                hint: Text("Pilih Hari"),
                isExpanded: true,
                items: _hariList.map((String hari) {
                  return DropdownMenuItem<String>(
                    value: hari,
                    child: Text(hari),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedHari = newValue;
                  });
                },
                validator: (value) => value == null ? 'Hari wajib dipilih' : null,
              ),
              SizedBox(height: 16),
              
              // --- Pilih Jam ---
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.access_time),
                      label: Text(_jamMulai == null ? "Jam Mulai" : _jamMulai!.format(context)),
                      onPressed: () => _pilihJam(true),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.access_time_filled),
                      label: Text(_jamSelesai == null ? "Jam Selesai" : _jamSelesai!.format(context)),
                      onPressed: () => _pilihJam(false),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // --- Input Ruangan ---
              TextFormField(
                controller: _ruanganC,
                decoration: InputDecoration(labelText: "Lokasi/Ruangan"),
                validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
              ),
              SizedBox(height: 30),

              // --- Tombol Simpan ---
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Simpan Jadwal"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50) // Lebar penuh
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}