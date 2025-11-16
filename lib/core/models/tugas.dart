// lib/core/models/tugas.dart
// Ini untuk dikerja pengerja fitur Tambah Tugas/Kuis/UTS/UAS (bisa dirombak)
class Tugas {
  final String id;
  final String mataKuliahId; // Kunci penghubung
  final String jenis; // "Tugas", "Kuis", "UTS", "UAS"
  final String deskripsi;
  final DateTime tenggatWaktu;

  Tugas({
    required this.id,
    required this.mataKuliahId,
    required this.jenis,
    required this.deskripsi,
    required this.tenggatWaktu,
  }); // Akhir Tugas
}