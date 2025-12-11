// lib/core/models/tugas.dart
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
  // final String? attachmentPath; 
  
  // [BARU] Status Pengerjaan
  final String status;

  // [BARU] Zona Waktu (WIB, WITA, WIT) - Default 'WITA' untuk backward compatibility
  final String zonaWaktu;

  // [BARU] Nama Mata Kuliah (Hasil Join/Lookup) - Tidak disimpan di tabel tugas
  final String? mataKuliahName;

  Tugas({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.type,
    required this.dueAt,
    required this.createdAt,
    required this.mataKuliahId,
    this.note,
    // this.attachmentPath,
    this.status = 'Belum Dikerjakan', // Default value
    this.zonaWaktu = 'WITA', // [BARU] Default ke WITA
    this.mataKuliahName,
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
      // attachmentPath: map['attachment_path'],
      // Ambil status, default ke 'Belum Dikerjakan' jika null (safety)
      status: map['status'] ?? 'Belum Dikerjakan',
      
      // [BARU] Ambil zona waktu, default 'WITA' jika null (untuk data lama)
      zonaWaktu: map['zona_waktu'] ?? 'WITA',
      
      // Jika kita melakukan join query di Supabase (.select('*, mata_kuliah(nama_matkul)'))
      // Data akan ada di map['mata_kuliah']['nama_matkul']
      mataKuliahName: map['mata_kuliah'] != null 
          ? map['mata_kuliah']['nama_matkul'] 
          : null,
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
      // 'attachment_path': attachmentPath, 
      'status': status, // Kirim status ke DB
      'zona_waktu': zonaWaktu, // [BARU] Kirim zona waktu
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
    String? status,
    String? zonaWaktu, // [BARU]
    String? mataKuliahName,
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
      status: status ?? this.status,
      zonaWaktu: zonaWaktu ?? this.zonaWaktu,
      mataKuliahName: mataKuliahName ?? this.mataKuliahName,
    );
  }
}