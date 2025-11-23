// lib/data/local/app_database.dart

import 'package:drift/drift.dart';

// Pilih koneksi web atau app
import 'app_database.native.dart'
    if (dart.library.html) 'app_database.web.dart';

part 'app_database.g.dart';

// Definisikan tabel berdasarkan model
class MataKuliahs extends Table {
  TextColumn get id => text()();
  TextColumn get nama => text().withLength(min: 1, max: 100)();
  TextColumn get dosen => text().withLength(min: 1, max: 100)();
  IntColumn get sks => integer()();

  @override
  Set<Column> get primaryKey => {id};
} 

class Jadwals extends Table {
  TextColumn get id => text()();
  TextColumn get mataKuliahId => text().references(MataKuliahs, #id)();
  TextColumn get hari => text()();
  DateTimeColumn get jamMulai => dateTime()();
  DateTimeColumn get jamSelesai => dateTime()();
  TextColumn get ruangan => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// --- TAMBAHAN BARU (Fitur Tugas & Bagian Eka) ---
class Tugass extends Table {
  TextColumn get id => text()();
  TextColumn get mataKuliahId => text().references(MataKuliahs, #id)();
  TextColumn get jenis => text()();
  TextColumn get deskripsi => text()();
  DateTimeColumn get tenggatWaktu => dateTime()();
  
  // Kolom baru untuk menyimpan Path File (PDF/Image)
  // nullable() artinya boleh kosong (tidak wajib upload file)
  TextColumn get attachmentPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
// --- AKHIR TAMBAHAN BARU ---

@DriftDatabase(tables: [MataKuliahs, Jadwals, Tugass])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connect()); 

  // Naikkan versi schema karena kita menambah kolom baru
  @override
  int get schemaVersion => 2; 

  // Migrasi sederhana: Jika versi naik, database lama akan dihapus & dibuat ulang.
  // Untuk production, perlu logic migrasi yang lebih kompleks (ALTER TABLE).
  // Tapi untuk tugas kuliah, ini cara tercepat agar tidak error.
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (Migrator m, int from, int to) async {
        // Hapus semua tabel dan buat ulang (WARNING: DATA HILANG)
        // Jika ingin mempertahankan data, kamu perlu belajar "Drift Migration"
        // atau cukup uninstall aplikasi di emulator sebelum run ulang.
         if (from < 2) {
           await m.addColumn(tugass, tugass.attachmentPath);
         }
      },
    );
  }
}