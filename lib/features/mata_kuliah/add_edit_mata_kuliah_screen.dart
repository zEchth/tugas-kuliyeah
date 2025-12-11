// lib/features/mata_kuliah/add_edit_mata_kuliah_screen.dart
// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart' as core_model;
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:uuid/uuid.dart';

class AddEditMataKuliahScreen extends ConsumerStatefulWidget {
  final core_model.MataKuliah? matkul;

  const AddEditMataKuliahScreen({super.key, this.matkul});

  @override
  ConsumerState<AddEditMataKuliahScreen> createState() =>
      _AddEditMataKuliahScreenState();
}

class _AddEditMataKuliahScreenState
    extends ConsumerState<AddEditMataKuliahScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaC;
  late TextEditingController _dosenC;
  late TextEditingController _sksC;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.matkul != null;

    _namaC = TextEditingController(text: _isEditing ? widget.matkul!.nama : '');
    _dosenC = TextEditingController(
      text: _isEditing ? widget.matkul!.dosen : '',
    );
    _sksC = TextEditingController(
      text: _isEditing ? widget.matkul!.sks.toString() : '',
    );
  }

  @override
  void dispose() {
    _namaC.dispose();
    _dosenC.dispose();
    _sksC.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(taskRepositoryProvider);

    final user = ref.read(userProvider);
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User tidak ditemukan")));
      return;
    }

    final mk = core_model.MataKuliah(
      id: _isEditing ? widget.matkul!.id : const Uuid().v4(),
      ownerId: user.id, // RLS butuh owner_id = auth.uid()
      nama: _namaC.text.trim(),
      dosen: _dosenC.text.trim(),
      sks: int.parse(_sksC.text),
      createdAt: _isEditing
          ? widget.matkul!.createdAt
          : DateTime.now(), // WAJIB untuk NOT NULL
    );

    try {
      if (_isEditing) {
        await repo.updateMataKuliah(mk);
      } else {
        await repo.insertMataKuliah(mk);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Mata kuliah disimpan!")));
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
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Mata Kuliah" : "Tambah Mata Kuliah"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaC,
                decoration: InputDecoration(labelText: "Nama Mata Kuliah"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              TextFormField(
                controller: _dosenC,
                decoration: InputDecoration(labelText: "Dosen Pengampu"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              TextFormField(
                controller: _sksC,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Jumlah SKS"),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Wajib diisi";
                  final sks = int.tryParse(v);
                  if (sks == null) return "Harus angka bulat";
                  if (sks <= 0) return "SKS harus > 0";
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submitForm, child: Text("Simpan")),
            ],
          ),
        ),
      ),
    );
  }
}