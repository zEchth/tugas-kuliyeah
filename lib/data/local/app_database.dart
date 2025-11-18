// lib/data/local/app_database.dart

// PASTIKAN import ini menggunakan 'package:drift/drift.dart'
import 'package:drift/drift.dart';

// Pilih koneksi web atau app
import 'app_database.native.dart'
    if (dart.library.html) 'app_database.web.dart';

// Perintah ini akan menghasilkan file baru setelah dijalankan
part 'app_database.g.dart';

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
  // Relasi ke tabel MataKuliahs
  TextColumn get mataKuliahId => text().references(MataKuliahs, #id)();
  TextColumn get hari => text()();
  DateTimeColumn get jamMulai => dateTime()();
  DateTimeColumn get jamSelesai => dateTime()();
  TextColumn get ruangan => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// --- TAMBAHAN BARU (Fitur Tugas) ---
// Tabel ini untuk menyimpan Tugas, Kuis, UTS, atau UAS
class Tugass extends Table {
  TextColumn get id => text()();
  // Relasi ke tabel MataKuliahs
  TextColumn get mataKuliahId => text().references(MataKuliahs, #id)();
  // Jenis: "Tugas", "Kuis", "UTS", "UAS"
  TextColumn get jenis => text()();
  TextColumn get deskripsi => text()();
  DateTimeColumn get tenggatWaktu => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
// --- AKHIR TAMBAHAN BARU ---

// --- DAFTARKAN TABEL DI SINI ---
@DriftDatabase(tables: [MataKuliahs, Jadwals, Tugass])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connect()); // Menggunakan fungsi connect() yang diimpor

  // Versi schema database harus selalu di-increment jika ada perubahan struktur tabel
  @override
  int get schemaVersion => 1;
} // Akhir dari AppDatabase
