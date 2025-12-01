// lib/core/models/jadwal.dart

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

  // [BARU] Logika Status Jadwal
  // Status: "Mendatang", "Berlangsung", "Selesai"
  String getStatus(DateTime now) {
    // 1. Cek Hari
    final List<String> hariList = [
      "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"
    ];
    
    // Konversi hari string ke weekday int (1=Senin, 7=Minggu)
    final int jadwalWeekday = hariList.indexOf(hari) + 1;
    
    if (jadwalWeekday == 0) return "Jadwal Error"; // Hari tidak valid

    // Jika hari ini bukan harinya jadwal
    if (now.weekday != jadwalWeekday) {
      if (now.weekday < jadwalWeekday) {
        return "Mendatang"; // Hari ini Senin, Jadwal Rabu -> Mendatang
      } else {
        return "Selesai"; // Hari ini Rabu, Jadwal Senin -> Selesai (minggu ini)
      }
    }

    // 2. Jika Hari INI Sama, Cek Jam
    // Normalisasi ke menit sejak jam 00:00
    final int nowMinutes = now.hour * 60 + now.minute;
    final int startMinutes = jamMulai.hour * 60 + jamMulai.minute;
    final int endMinutes = jamSelesai.hour * 60 + jamSelesai.minute;

    if (nowMinutes < startMinutes) {
      return "Mendatang";
    } else if (nowMinutes >= startMinutes && nowMinutes <= endMinutes) {
      return "Berlangsung";
    } else {
      return "Selesai";
    }
  }
}