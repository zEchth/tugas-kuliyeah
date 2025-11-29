// lib/core/models/jadwal.dart
// class Jadwal {
//   final String id;
//   final String mataKuliahId; // Kunci penghubung
//   final String hari;
//   final DateTime jamMulai;
//   final DateTime jamSelesai;
//   final String ruangan;

//   Jadwal({
//     required this.id,
//     required this.mataKuliahId,
//     required this.hari,
//     required this.jamMulai,
//     required this.jamSelesai,
//     required this.ruangan,
//   }); // Akhir Jadwal
// }

class Jadwal {
  final String id;
  final String ownerId;
  final String hari;
  final DateTime jamMulai;
  final DateTime jamSelesai;
  final String? ruangan;
  final DateTime createdAt;
  final String mataKuliahId;

  Jadwal({
    required this.id,
    required this.ownerId,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangan,
    required this.createdAt,
    required this.mataKuliahId,
  });

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
      ownerId: map['owner_id'],
      hari: map['hari'],
      jamMulai: DateTime.parse("2025-01-01 ${map['jam_mulai']}"),
      jamSelesai: DateTime.parse("2025-01-01 ${map['jam_selesai']}"),
      ruangan: map['ruangan'],
      createdAt: DateTime.parse(map['created_at']),
      mataKuliahId: map['mata_kuliah_id'],
    );
  }

  // ----- TO SUPABASE -----
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'hari': hari,

      // DateTime -> TIME (tanpa tanggal)
      'jam_mulai': _toPgTime(jamMulai),
      'jam_selesai': _toPgTime(jamSelesai),
      
      'ruangan': ruangan,
      'created_at': createdAt.toIso8601String(),
      'mata_kuliah_id': mataKuliahId,
    };
  }
}
