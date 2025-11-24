// lib/core/repositories/task_repository.dart
import 'package:tugas_kuliyeah/core/models/jadwal.dart' as core_model;
import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart' as core_model;
import 'package:tugas_kuliyeah/core/models/tugas.dart' as core_model;

// KONTRAK semua penyimpanan data (lokal)
abstract class TaskRepository {
  // -- Fitur Tambah Mata Kuliah & Jadwal Kuliah --
  Future<void> addMataKuliah(core_model.MataKuliah mataKuliah);
  Future<void> addJadwal(core_model.Jadwal jadwal);

  Stream<List<core_model.MataKuliah>> watchAllMataKuliah();
  Stream<List<core_model.Jadwal>> watchJadwalByMataKuliah(String mataKuliahId);

  Future<void> updateMataKuliah(core_model.MataKuliah mataKuliah);
  Future<void> deleteMataKuliah(String mataKuliahId);

  Future<void> updateJadwal(core_model.Jadwal jadwal);
  Future<void> deleteJadwal(String jadwalId);

  // --- TAMBAHAN BARU (Fitur Tugas) ---
  // (Sebelumnya di-comment, sekarang kita aktifkan dan tambahkan)
  Future<void> addTugas(core_model.Tugas tugas);
  Future<void> updateTugas(core_model.Tugas tugas);
  Future<void> deleteTugas(String tugasId);
  // Kita ganti 'watchAllTugas' menjadi 'watchTugasByMataKuliah' agar lebih spesifik
  Stream<List<core_model.Tugas>> watchTugasByMataKuliah(String mataKuliahId);
  // --- AKHIR TAMBAHAN BARU ---

  // -- Untuk dikerja pengerja Fitur Tambah Detail Tugas (bisa dirombak) --
  // Future<void> addDetailTugas(String tugasId, String filePath);

  // -- untuk dikerja pengerja Fitur Reminder Tugas, Jam Kuliah, & Ruangan (bisa dirombak) --
  // Future<List<Tugas>> getTugasMendatang();
  // Future<List<Jadwal>> getJadwalHariIni();

  // -- Fitur-fitur lain
}
