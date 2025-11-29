// lib/core/models/tugas.dart
// class Tugas {
//   final String id;
//   final String mataKuliahId; // Kunci penghubung
//   final String jenis; // "Tugas", "Kuis", "UTS", "UAS"
//   final String deskripsi;
//   final DateTime tenggatWaktu;

//   // --- BAGIAN EKA (Fitur 5) ---
//   final String? attachmentPath; // Path lokasi file (PDF/Image) di HP
//   // ----------------------------

//   Tugas({
//     required this.id,
//     required this.mataKuliahId,
//     required this.jenis,
//     required this.deskripsi,
//     required this.tenggatWaktu,
//     this.attachmentPath, // Bisa null jika tidak ada file
//   });
// }

class Tugas {
  final String id;
  final String ownerId;
  final String title; // judul tugas
  final String type;  // jenis tugas
  final String? note; // deskripsi
  final DateTime dueAt; // tenggat waktu
  final DateTime createdAt;
  final String mataKuliahId;
  // --- BAGIAN EKA (Fitur 5) ---
  final String? attachmentPath; 

  Tugas({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.type,
    required this.dueAt,
    required this.createdAt,
    required this.mataKuliahId,
    this.note,
    this.attachmentPath,
  });

  factory Tugas.fromMap(Map<String, dynamic> map) {
    return Tugas(
      id: map['id'],
      ownerId: map['owner_id'],
      title: map['title'],       // NOT NULL → pasti ada
      type: map['type'],         // NOT NULL → pasti ada
      note: map['note'],         // boleh null
      dueAt: DateTime.parse(map['due_at']),
      createdAt: DateTime.parse(map['created_at']),
      mataKuliahId: map['mata_kuliah_id'],
      attachmentPath: map['attachment_path'], 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,     // wajib
      'type': type,       // wajib
      'note': note,       // nullable
      'due_at': dueAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'mata_kuliah_id': mataKuliahId,
      'attachment_path': attachmentPath, 
    };
  }
}
