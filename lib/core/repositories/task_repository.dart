import 'package:tugas_kuliyeah/core/models/jadwal.dart';
import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart';
import 'package:tugas_kuliyeah/core/models/tugas.dart';

// KONTRAK semua penyimpanan data (lokal)
abstract class TaskRepository {
  // -- Fitur Tambah Mata Kuliah & Jadwal Kuliah --
  Future<void> addMataKuliah(MataKuliah mataKuliah);
  Future<void> addJadwal(Jadwal jadwal);
  Future<List<MataKuliah>> getAllMataKuliah();
  Future<List<Jadwal>> getJadwalByMataKuliah(String mataKuliahId);

  // -- Untuk dikerja oleh pengerja Fitur Tambah Tugas/Kuis/UTS/UAS (bisa dirombak) --
  Future<void> addTugas(Tugas tugas);
  Future<List<Tugas>> getAllTugas();

  // -- Untuk dikerja pengerja Fitur Tambah Detail Tugas (bisa dirombak) -- 
  Future<void> addDetailTugas(String tugasId, String filePath);

  // -- untuk dikerja pengerja Fitur Reminder Tugas, Jam Kuliah, & Ruangan
  Future<List<Tugas>> getTugasMendatang();
  Future<List<Jadwal>> getJadwalHariIni();
}