// lib/core/models/jadwal.dart

class Jadwal {
  final String id;
  final String batchId;
  final String ownerId;
  final DateTime tanggal;
  
  final String judul;
  final String statusPertemuan;
  final DateTime jamMulai;
  final DateTime jamSelesai;
  final String? ruangan;
  final DateTime createdAt;
  final String mataKuliahId;
  final String? mataKuliahName;

  Jadwal({
    required this.id,
    required this.batchId,
    required this.ownerId,
    required this.tanggal,
    required this.judul,
    this.statusPertemuan = 'Terjadwal',
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangan,
    required this.createdAt,
    required this.mataKuliahId,
    this.mataKuliahName,
  });

  String get hari {
    const hariList = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"];
    return hariList[tanggal.weekday - 1];
  }

  static String _toPgTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  factory Jadwal.fromMap(Map<String, dynamic> map) {
    return Jadwal(
      id: map['id'],
      batchId: map['batch_id'] ?? '',
      ownerId: map['owner_id'],
      tanggal: DateTime.parse(map['tanggal']),
      
      judul: map['judul'] ?? 'Jadwal', 
      
      statusPertemuan: map['status_pertemuan'] ?? 'Terjadwal',
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batch_id': batchId,
      'owner_id': ownerId,
      'tanggal': tanggal.toIso8601String().split('T')[0], 
      
      'judul': judul,
      'status_pertemuan': statusPertemuan,
      'jam_mulai': _toPgTime(jamMulai),
      'jam_selesai': _toPgTime(jamSelesai),
      'ruangan': ruangan,
      'created_at': createdAt.toIso8601String(),
      'mata_kuliah_id': mataKuliahId,
    };
  }

  String getStatus(DateTime now) {
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
  
  Jadwal copyWith({
    String? id,
    String? batchId,
    String? ownerId,
    DateTime? tanggal,
    String? judul,
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