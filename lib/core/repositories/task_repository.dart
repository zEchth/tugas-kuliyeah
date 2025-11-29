// lib/core/repositories/task_repository.dart
import 'package:tugas_kuliyeah/core/models/jadwal.dart' as core_model;
import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart' as core_model;
import 'package:tugas_kuliyeah/core/models/share_tugas.dart';
import 'package:tugas_kuliyeah/core/models/tugas.dart' as core_model;

// KONTRAK semua penyimpanan data (lokal)
// abstract class TaskRepository {
//   // -- Fitur Tambah Mata Kuliah & Jadwal Kuliah --
//   Future<void> addMataKuliah(core_model.MataKuliah mataKuliah);
//   Future<void> addJadwal(core_model.Jadwal jadwal);

//   Stream<List<core_model.MataKuliah>> watchAllMataKuliah();
//   Stream<List<core_model.Jadwal>> watchJadwalByMataKuliah(String mataKuliahId);

//   Future<void> updateMataKuliah(core_model.MataKuliah mataKuliah);
//   Future<void> deleteMataKuliah(String mataKuliahId);

//   Future<void> updateJadwal(core_model.Jadwal jadwal);
//   Future<void> deleteJadwal(String jadwalId);

//   // --- TAMBAHAN BARU (Fitur Tugas) ---
//   // (Sebelumnya di-comment, sekarang kita aktifkan dan tambahkan)
//   Future<void> addTugas(core_model.Tugas tugas);
//   Future<void> updateTugas(core_model.Tugas tugas);
//   Future<void> deleteTugas(String tugasId);
//   // Kita ganti 'watchAllTugas' menjadi 'watchTugasByMataKuliah' agar lebih spesifik
//   Stream<List<core_model.Tugas>> watchTugasByMataKuliah(String mataKuliahId);
//   // --- AKHIR TAMBAHAN BARU ---

//   // -- Untuk dikerja pengerja Fitur Tambah Detail Tugas (bisa dirombak) --
//   // Future<void> addDetailTugas(String tugasId, String filePath);

//   // -- untuk dikerja pengerja Fitur Reminder Tugas, Jam Kuliah, & Ruangan (bisa dirombak) --
//   // Future<List<Tugas>> getTugasMendatang();
//   // Future<List<Jadwal>> getJadwalHariIni();

//   // -- Fitur-fitur lain
//   Future<void> shareTugas({
//     required String tugasId,
//     required String receiverEmail,
//   });
// }

abstract class TaskRepository {
  // ===================== MATA KULIAH =====================
  Stream<List<core_model.MataKuliah>> watchAllMataKuliah();
  Future<void> insertMataKuliah(core_model.MataKuliah mk);
  Future<void> updateMataKuliah(core_model.MataKuliah mk);
  Future<void> deleteMataKuliah(String id);

  // ======================== JADWAL ========================
  Stream<List<core_model.Jadwal>> watchJadwalByMataKuliah(String matkulId);
  Future<void> insertJadwal(core_model.Jadwal jadwal);
  Future<void> updateJadwal(core_model.Jadwal jadwal);
  Future<void> deleteJadwal(String id);

  // ========================= TUGAS ========================
  Stream<List<core_model.Tugas>> watchTugasByMataKuliah(String matkulId);
  Future<void> insertTugas(core_model.Tugas tugas);
  Future<void> updateTugas(core_model.Tugas tugas);
  Future<void> deleteTugas(String id);

  // ===================== SHARE TUGAS ======================
  Future<void> shareTugas({
    required String tugasId,
    required String receiverEmail,
  });

  Stream<List<ShareTugas>> watchSharedTasksReceived(String myUserId);
  Stream<List<ShareTugas>> watchSharedTasksSent(String myUserId);
}
