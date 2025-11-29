// lib/core/models/mata_kuliah.dart
// class MataKuliah {
//   final String id;
//   final String nama;
//   final String dosen;
//   final int sks;

//   MataKuliah ({
//     required this.id,
//     required this.nama,
//     required this.dosen,
//     required this.sks,
//   }); // Akhir MataKuliah
// }

class MataKuliah {
  final String id;
  final String ownerId;
  final String nama;
  final String dosen;
  final int sks;
  final DateTime createdAt;

  MataKuliah({
    required this.id,
    required this.ownerId,
    required this.nama,
    required this.dosen,
    required this.sks,
    required this.createdAt,
  });

  // ----- FROM SUPABASE -----
  factory MataKuliah.fromMap(Map<String, dynamic> map) {
    return MataKuliah(
      id: map['id'],
      ownerId: map['owner_id'],
      nama: map['nama_matkul'],
      dosen: map['dosen_matkul'],
      sks: map['sks'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // ----- TO SUPABASE -----
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'nama_matkul': nama,
      'dosen_matkul': dosen,
      'sks': sks,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
