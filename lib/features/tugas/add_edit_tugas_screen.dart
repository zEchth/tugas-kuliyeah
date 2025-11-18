// lib/features/tugas/add_edit_tugas_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tugas_kuliyeah/core/models/tugas.dart' as core_model;
import 'package:tugas_kuliyeah/core/providers.dart';

class AddEditTugasScreen extends ConsumerStatefulWidget {
  final String mataKuliahId;
  final core_model.Tugas? tugas; // Mode Edit jika tidak null

  const AddEditTugasScreen({super.key, required this.mataKuliahId, this.tugas});

  @override
  ConsumerState<AddEditTugasScreen> createState() => _AddEditTugasScreenState();
}

class _AddEditTugasScreenState extends ConsumerState<AddEditTugasScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  // Controllers
  late TextEditingController _deskripsiC;
  String? _selectedJenis;
  DateTime? _tenggatWaktu;

  final List<String> _jenisList = ["Tugas", "Kuis", "UTS", "UAS"];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.tugas != null;

    _deskripsiC = TextEditingController(
      text: _isEditing ? widget.tugas!.deskripsi : '',
    );
    _selectedJenis = _isEditing ? widget.tugas!.jenis : null;
    _tenggatWaktu = _isEditing ? widget.tugas!.tenggatWaktu : null;
  }

  @override
  void dispose() {
    _deskripsiC.dispose();
    super.dispose();
  }

  Future<void> _pilihTenggat() async {
    // 1. Pilih Tanggal
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _tenggatWaktu ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return; // User batal

    // 2. Pilih Jam
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_tenggatWaktu ?? DateTime.now()),
    );

    if (pickedTime == null) return; // User batal

    // 3. Gabungkan
    setState(() {
      _tenggatWaktu = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _submitForm() async {
    // Validasi manual
    if (_formKey.currentState!.validate() &&
        _selectedJenis != null &&
        _tenggatWaktu != null) {
      final repository = ref.read(taskRepositoryProvider);

      final tugasBaru = core_model.Tugas(
        id: _isEditing ? widget.tugas!.id : Random().nextInt(99999).toString(),
        mataKuliahId: widget.mataKuliahId,
        jenis: _selectedJenis!,
        deskripsi: _deskripsiC.text,
        tenggatWaktu: _tenggatWaktu!,
      );

      try {
        if (_isEditing) {
          await repository.updateTugas(tugasBaru);
        } else {
          await repository.addTugas(tugasBaru);
        }

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Tugas Disimpan!")));
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Harap lengkapi semua data tugas.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? "Edit Tugas" : "Tambah Tugas")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Pilih Jenis ---
              DropdownButtonFormField<String>(
                value: _selectedJenis,
                hint: Text("Pilih Jenis"),
                isExpanded: true,
                items: _jenisList.map((String jenis) {
                  return DropdownMenuItem<String>(
                    value: jenis,
                    child: Text(jenis),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedJenis = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Jenis wajib dipilih' : null,
              ),
              SizedBox(height: 16),

              // --- Input Deskripsi ---
              TextFormField(
                controller: _deskripsiC,
                decoration: InputDecoration(labelText: "Deskripsi"),
                validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
              ),
              SizedBox(height: 16),

              // --- Pilih Tenggat Waktu ---
              ElevatedButton.icon(
                icon: Icon(Icons.calendar_today),
                label: Text(
                  _tenggatWaktu == null
                      ? "Pilih Tenggat Waktu"
                      : DateFormat('dd MMM yyyy, HH:mm').format(_tenggatWaktu!),
                ),
                onPressed: _pilihTenggat,
              ),
              SizedBox(height: 30),

              // --- Tombol Simpan ---
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Simpan Tugas"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Lebar penuh
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
