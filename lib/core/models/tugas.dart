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
  
  // [BARU] Status Pengerjaan
  final String status;

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
    this.status = 'Belum Dikerjakan', // Default value
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
      // Ambil status, default ke 'Belum Dikerjakan' jika null (safety)
      status: map['status'] ?? 'Belum Dikerjakan', 
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
      'status': status, // Kirim status ke DB
    };
  }
  
  // Helper copyWith untuk update state status dengan mudah
  Tugas copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? type,
    String? note,
    DateTime? dueAt,
    DateTime? createdAt,
    String? mataKuliahId,
    String? attachmentPath,
    String? status,
  }) {
    return Tugas(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      type: type ?? this.type,
      note: note ?? this.note,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      mataKuliahId: mataKuliahId ?? this.mataKuliahId,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      status: status ?? this.status,
    );
  }
}