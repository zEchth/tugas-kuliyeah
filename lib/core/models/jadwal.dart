// lib/core/models/jadwal.dart

class Jadwal {
  final String id;
  // [BARU] batchId untuk mengelompokkan 1 semester jadwal
  final String batchId;
  final String ownerId;
  
  // [HAPUS] final String hari; -> Diganti tanggal spesifik
  // [BARU] Tanggal spesifik pertemuan (YYYY-MM-DD)
  final DateTime tanggal;
  
  // [LEGACY] Pertemuan ke-berapa (tetap disimpan tapi tidak lagi menjadi penentu judul)
  final int pertemuanKe;
  
  // [BARU] Judul Persisten (String bebas)
  final String judul;
  
  // [BARU] Status per pertemuan (Terjadwal, Selesai, Libur, dll)
  final String statusPertemuan;

  final DateTime jamMulai;
  final DateTime jamSelesai;
  final String? ruangan;
  final DateTime createdAt;
  final String mataKuliahId;
  
  // [BARU] Nama Mata Kuliah (Hasil Join/Lookup)
  final String? mataKuliahName;

  Jadwal({
    required this.id,
    required this.batchId,
    required this.ownerId,
    required this.tanggal,
    required this.pertemuanKe,
    required this.judul, // [BARU]
    this.statusPertemuan = 'Terjadwal',
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangan,
    required this.createdAt,
    required this.mataKuliahId,
    this.mataKuliahName,
  });

  // [COMPATIBILITY LAYER]
  // Agar UI lama yang memanggil .hari tidak error, kita hitung dinamis dari tanggal
  String get hari {
    const hariList = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"];
    // weekday di Dart mulai dari 1 (Senin) sampai 7 (Minggu)
    return hariList[tanggal.weekday - 1];
  }

  // Convert DateTime -> TIME string for PostgreSQL
  static String _toPgTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  // ----- FROM SUPABASE -----
  factory Jadwal.fromMap(Map<String, dynamic> map) {
    return Jadwal(
      id: map['id'],
      batchId: map['batch_id'] ?? '', // Safety check jika data lama null
      ownerId: map['owner_id'],
      
      // Parsing Tanggal (Date Only)
      tanggal: DateTime.parse(map['tanggal']),
      pertemuanKe: map['pertemuan_ke'] ?? 1,
      
      // [BARU] Ambil Judul. Fallback ke format lama jika kolom judul masih null (data lama)
      judul: map['judul'] ?? 'Pertemuan ke-${map['pertemuan_ke'] ?? "?"}',
      
      statusPertemuan: map['status_pertemuan'] ?? 'Terjadwal',

      // Parsing Jam (Time Only) - Kita tempel ke dummy date agar jadi DateTime object
      jamMulai: DateTime.parse("2025-01-01 ${map['jam_mulai']}"),
      jamSelesai: DateTime.parse("2025-01-01 ${map['jam_selesai']}"),
      
      ruangan: map['ruangan'],
      createdAt: DateTime.parse(map['created_at']),
      mataKuliahId: map['mata_kuliah_id'],
      
      mataKuliahName: map['mata_kuliah'] != null 
          ? map['mata_kuliah']['nama_matkul'] 
          : null,
    );
  }

  // ----- TO SUPABASE -----
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batch_id': batchId,
      'owner_id': ownerId,
      
      // DateTime -> Date String (YYYY-MM-DD)
      'tanggal': tanggal.toIso8601String().split('T')[0],
      'pertemuan_ke': pertemuanKe,
      'judul': judul, // [BARU]
      'status_pertemuan': statusPertemuan,

      // DateTime -> TIME (tanpa tanggal)
      'jam_mulai': _toPgTime(jamMulai),
      'jam_selesai': _toPgTime(jamSelesai),
      
      'ruangan': ruangan,
      'created_at': createdAt.toIso8601String(),
      'mata_kuliah_id': mataKuliahId,
    };
  }

  // [UPDATED] Logika Status Jadwal (Jauh lebih akurat sekarang)
  String getStatus(DateTime now) {
    // 1. Bandingkan Tanggal Dulu
    // Kita buat object DateTime lengkap (Tanggal Real + Jam Real)
    final startDateTime = DateTime(
      tanggal.year, 
      tanggal.month, 
      tanggal.day, 
      jamMulai.hour, 
      jamMulai.minute
    );
    
    final endDateTime = DateTime(
      tanggal.year, 
      tanggal.month, 
      tanggal.day, 
      jamSelesai.hour, 
      jamSelesai.minute
    );

    if (now.isBefore(startDateTime)) {
      return "Mendatang";
    } else if (now.isAfter(endDateTime)) {
      return "Selesai";
    } else {
      return "Berlangsung";
    }
  }
  
  // Helper copyWith
  Jadwal copyWith({
    String? id,
    String? batchId,
    String? ownerId,
    DateTime? tanggal,
    int? pertemuanKe,
    String? judul, // [BARU]
    String? statusPertemuan,
    DateTime? jamMulai,
    DateTime? jamSelesai,
    String? ruangan,
    DateTime? createdAt,
    String? mataKuliahId,
    String? mataKuliahName,
  }) {
    return Jadwal(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      ownerId: ownerId ?? this.ownerId,
      tanggal: tanggal ?? this.tanggal,
      pertemuanKe: pertemuanKe ?? this.pertemuanKe,
      judul: judul ?? this.judul,
      statusPertemuan: statusPertemuan ?? this.statusPertemuan,
      jamMulai: jamMulai ?? this.jamMulai,
      jamSelesai: jamSelesai ?? this.jamSelesai,
      ruangan: ruangan ?? this.ruangan,
      createdAt: createdAt ?? this.createdAt,
      mataKuliahId: mataKuliahId ?? this.mataKuliahId,
      mataKuliahName: mataKuliahName ?? this.mataKuliahName,
    );
  }
}