// lib/core/models/jadwal.dart
class Jadwal {
  final String id;
  final String mataKuliahId; // Kunci penghubung
  final String hari;
  final DateTime jamMulai;
  final DateTime jamSelesai;
  final String ruangan;

  Jadwal({
    required this.id,
    required this.mataKuliahId,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangan,
  }); // Akhir Jadwal
}