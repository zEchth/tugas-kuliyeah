// lib/core/models/tugas.dart
class Tugas {
  final String id;
  final String mataKuliahId; // Kunci penghubung
  final String jenis; // "Tugas", "Kuis", "UTS", "UAS"
  final String deskripsi;
  final DateTime tenggatWaktu;
  
  // --- BAGIAN EKA (Fitur 5) ---
  final String? attachmentPath; // Path lokasi file (PDF/Image) di HP
  // ----------------------------

  Tugas({
    required this.id,
    required this.mataKuliahId,
    required this.jenis,
    required this.deskripsi,
    required this.tenggatWaktu,
    this.attachmentPath, // Bisa null jika tidak ada file
  });
}