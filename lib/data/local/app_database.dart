// lib/data/local/app_database.dart

import 'package:drift/drift.dart';

// Pilih koneksi web atau app
import 'app_database.native.dart' if (dart.library.html) 'app_database.web.dart';

// Perintah ini akan menghasilkan file baru setelah dijalankan
part 'app_database.g.dart';

// Impor model masih agak manual, bisa diotomatisasi
// Definisikan tabel berdasarkan model
class MataKuliahs extends Table {
  TextColumn get id => text()();
  TextColumn get nama => text().withLength(min: 1, max: 100)();
  TextColumn get dosen => text().withLength(min: 1, max: 100)();
  IntColumn get sks => integer()();

  @override
  Set<Column> get primaryKey => {id};
} // Akhir MataKuliahs

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

// Tabel tugas juga perlu dibuat disini (tugas pengerja Fitur Tambah Tugas/Kuis/UTS/UAS)

@DriftDatabase(tables: [MataKuliahs, Jadwals])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connect()); // Menggunakan fungsi connect() yang diimpor
  
  @override
  int get schemaVersion => 1;
} // Akhir dari AppDatabase
