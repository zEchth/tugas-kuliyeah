// lib/features/mata_kuliah/add_mata_kuliah_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart';
import 'package:tugas_kuliyeah/core/providers.dart';
import 'dart:math';

// Pakai ConsumerWidget agar bisa 'listen' ke provider
class AddMataKuliahScreen extends ConsumerWidget {
  AddMataKuliahScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _namaC = TextEditingController();
  final _dosenC = TextEditingController();
  final _sksC = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Mata Kuliah")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaC,
                decoration: InputDecoration(labelText: "Nama Mata Kuliah"),
                validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
              ),
              TextFormField(
                controller: _dosenC,
                decoration: InputDecoration(labelText: "Dosen Pengampu"),
                validator: (val) => val!.isEmpty ? "Wajib diisi":null,
              ),
              TextFormField(
                controller: _sksC,
                decoration: InputDecoration(labelText: "Jumlah SKS"),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Wajib diisi";
                  }
                  // Tambahkan pengecekan apakah nilainya bisa diparsing sebagai integer
                  if (int.tryParse(val) == null) {
                    return "Harus berupa angka bulat";
                  }
                  return null; // Validasi berhasil
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                      // 1. Buat modelnya
                    final newMataKuliah = MataKuliah(
                      id: Random().nextInt(99999).toString(),
                      nama: _namaC.text,
                      dosen: _dosenC.text,
                      sks: int.parse(_sksC.text),
                      );

                      try {
                        // 2. Panggil REPOSITORY via provider
                        await ref
                            .read(taskRepositoryProvider)
                            .addMataKuliah(newMataKuliah);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Mata Kuliah Disimpan!")),
                        );

                        // Reset form
                        _formKey.currentState?.reset();

                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Error: $e")),
                        );
                      }
                  }
                },
                child: Text("Simpan"),
              )
            ],
            )
          )
      )
    );
  }  
} // Akhir AddMataKuliahScreen