// lib/data/repositories/local_task_repository.dart
import 'package:drift/drift.dart';
import 'package:tugas_kuliyeah/core/repositories/task_repository.dart';

import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart' as core_model;
import 'package:tugas_kuliyeah/core/models/jadwal.dart' as core_model;
import 'package:tugas_kuliyeah/core/models/tugas.dart' as core_model;

import 'package:tugas_kuliyeah/data/local/app_database.dart';

// Implementasi 'TaskRepository' (Kontrak)
class LocalTaskRepository implements TaskRepository {
  final AppDatabase db;
  LocalTaskRepository(this.db);

  @override
  Future<void> addMataKuliah(core_model.MataKuliah matakuliah) async {
    // Konversi model 'core' ke model tabel 'drift'
    final matkulCompanion = MataKuliahsCompanion.insert(
      id: matakuliah.id,
      nama: matakuliah.nama,
      dosen: matakuliah.dosen, // Bungkus Value() jika dosen nullable
      sks: matakuliah.sks,
    ); // Akhir matkulCompanion
    // Masukkan ke database
    await db.into(db.mataKuliahs).insert(matkulCompanion);
  }

  @override
  Future<void> addJadwal(core_model.Jadwal jadwal) async {
    final jadwalCompanion = JadwalsCompanion.insert(
      id: jadwal.id,
      mataKuliahId: jadwal.mataKuliahId,
      hari: jadwal.hari,
      jamMulai: jadwal.jamMulai,
      jamSelesai: jadwal.jamSelesai,
      ruangan: jadwal.ruangan, // Bungkus Value() jika ruangan nullable
    );
    await db.into(db.jadwals).insert(jadwalCompanion);
  }

  @override
  Future<List<core_model.MataKuliah>> getAllMataKuliah() async {
    // 1. Ambil semua data dari tabel MataKuliahs
    final allMatkul = await db.select(db.mataKuliahs).get();

    // 2. Konversi hasil (Drift Model) menjadi Core Model
    return allMatkul.map((matkulDrift) => core_model.MataKuliah(
      id: matkulDrift.id,
      nama: matkulDrift.nama,
      dosen: matkulDrift.dosen ?? '', // Berikan nilai default jika null
      sks: matkulDrift.sks,
    )).toList();
  }

  @override
  Future<List<core_model.Jadwal>> getJadwalByMataKuliah(String mataKuliahId) async {
    // 1. Lakukan query filter WHERE
    final query = db.select(db.jadwals)
        ..where((tbl) => tbl.mataKuliahId.equals(mataKuliahId));
    
    final result = await query.get();

    // 2. Konversi hasil (Drift Model) menjadi Core Model
    return result.map((jadwalDrift) => core_model.Jadwal(
      id: jadwalDrift.id,
      mataKuliahId: jadwalDrift.mataKuliahId,
      hari: jadwalDrift.hari,
      jamMulai: jadwalDrift.jamMulai,
      jamSelesai: jadwalDrift.jamSelesai,
      ruangan: jadwalDrift.ruangan ?? '',
      )).toList();
  }

  // Implementasikan fitur-fitur lainnya di sini
  // ...
}