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
      dosen: matakuliah.dosen,
      sks: matakuliah.sks,
    );
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
      ruangan: jadwal.ruangan,
    );
    await db.into(db.jadwals).insert(jadwalCompanion);
  }

  @override
  Stream<List<core_model.MataKuliah>> watchAllMataKuliah() {
    // 1. Ambil stream dari Drift
    final streamDrift = db.select(db.mataKuliahs).watch();

    // 2. Konversi stream (map) dari model Drift ke Core Model
    return streamDrift.map((listMatkulDrift) {
      // NOTE: Dosen dan Ruangan di model Core tidak nullable, tapi di model Drift mungkin.
      // Kita pakai operator '??' (null-aware) untuk memberi default string kosong
      return listMatkulDrift
          .map(
            (matkulDrift) => core_model.MataKuliah(
              id: matkulDrift.id,
              nama: matkulDrift.nama,
              dosen: matkulDrift.dosen,
              sks: matkulDrift.sks,
            ),
          )
          .toList();
    });
  }

  @override
  Stream<List<core_model.Jadwal>> watchJadwalByMataKuliah(String mataKuliahId) {
    // 1. Query stream dengan filter WHERE
    final queryStream = (db.select(
      db.jadwals,
    )..where((tbl) => tbl.mataKuliahId.equals(mataKuliahId))).watch();

    // 2. Konversi stream
    return queryStream.map((listJadwalDrift) {
      return listJadwalDrift
          .map(
            (jadwalDrift) => core_model.Jadwal(
              id: jadwalDrift.id,
              mataKuliahId: jadwalDrift.mataKuliahId,
              hari: jadwalDrift.hari,
              jamMulai: jadwalDrift.jamMulai,
              jamSelesai: jadwalDrift.jamSelesai,
              ruangan: jadwalDrift.ruangan,
            ),
          )
          .toList();
    });
  }

  @override
  Future<void> updateMataKuliah(core_model.MataKuliah mataKuliah) async {
    // Gunakan 'replace' yang berfungsi sebagai 'update'
    await db
        .update(db.mataKuliahs)
        .replace(
          MataKuliahsCompanion(
            id: Value(mataKuliah.id),
            nama: Value(mataKuliah.nama),
            dosen: Value(mataKuliah.dosen),
            sks: Value(mataKuliah.sks),
          ),
        );
  }

  @override
  Future<void> deleteMataKuliah(String mataKuliahId) async {
    // Query 'delete' dengan 'where'
    await (db.delete(
      db.mataKuliahs,
    )..where((tbl) => tbl.id.equals(mataKuliahId))).go();

    // PENTING: Hapus juga semua jadwal yang terkait!
    await (db.delete(
      db.jadwals,
    )..where((tbl) => tbl.mataKuliahId.equals(mataKuliahId))).go();

    // --- TAMBAHAN BARU: Hapus juga TUGAS yang terkait ---
    await (db.delete(
      db.tugass,
    )..where((tbl) => tbl.mataKuliahId.equals(mataKuliahId))).go();
  }

  @override
  Future<void> updateJadwal(core_model.Jadwal jadwal) async {
    await db
        .update(db.jadwals)
        .replace(
          JadwalsCompanion(
            id: Value(jadwal.id),
            mataKuliahId: Value(jadwal.mataKuliahId),
            hari: Value(jadwal.hari),
            jamMulai: Value(jadwal.jamMulai),
            jamSelesai: Value(jadwal.jamSelesai),
            ruangan: Value(jadwal.ruangan),
          ),
        );
  }

  @override
  Future<void> deleteJadwal(String jadwalId) async {
    await (db.delete(db.jadwals)..where((tbl) => tbl.id.equals(jadwalId))).go();
  }

  // --- IMPLEMENTASI BARU (Fitur Tugas) ---

  @override
  Future<void> addTugas(core_model.Tugas tugas) async {
    final tugasCompanion = TugassCompanion.insert(
      id: tugas.id,
      mataKuliahId: tugas.mataKuliahId,
      jenis: tugas.jenis,
      deskripsi: tugas.deskripsi,
      tenggatWaktu: tugas.tenggatWaktu,
    );
    await db.into(db.tugass).insert(tugasCompanion);
  }

  @override
  Future<void> updateTugas(core_model.Tugas tugas) async {
    await db
        .update(db.tugass)
        .replace(
          TugassCompanion(
            id: Value(tugas.id),
            mataKuliahId: Value(tugas.mataKuliahId),
            jenis: Value(tugas.jenis),
            deskripsi: Value(tugas.deskripsi),
            tenggatWaktu: Value(tugas.tenggatWaktu),
          ),
        );
  }

  @override
  Future<void> deleteTugas(String tugasId) async {
    await (db.delete(db.tugass)..where((tbl) => tbl.id.equals(tugasId))).go();
  }

  @override
  Stream<List<core_model.Tugas>> watchTugasByMataKuliah(String mataKuliahId) {
    // 1. Query stream dengan filter WHERE
    // Menggunakan db.select(db.tugass) tanpa casting manual
    final queryStream = (db.select(
      db.tugass,
    )..where((tbl) => tbl.mataKuliahId.equals(mataKuliahId))).watch();

    // 2. Konversi stream
    return queryStream.map((listTugasDrift) {
      return listTugasDrift
          .map(
            (tugasDrift) => core_model.Tugas(
              id: tugasDrift.id,
              mataKuliahId: tugasDrift.mataKuliahId,
              jenis: tugasDrift.jenis,
              deskripsi: tugasDrift.deskripsi,
              tenggatWaktu: tugasDrift.tenggatWaktu,
            ),
          )
          .toList();
    });
  }
}
