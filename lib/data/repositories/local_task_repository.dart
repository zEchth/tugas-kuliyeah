// import 'package:drift/drift.dart';
// import 'package:tugas_kuliyeah/core/repositories/task_repository.dart';
// // Service Notifikasi (Pastikan file ini sudah ada di lib/services/)
// import 'package:tugas_kuliyeah/services/notification_service.dart';

// import 'package:supabase_flutter/supabase_flutter.dart';

// // Model Import
// import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart' as core_model;
// import 'package:tugas_kuliyeah/core/models/jadwal.dart' as core_model;
// import 'package:tugas_kuliyeah/core/models/tugas.dart' as core_model;

// // Database Import
// import 'package:tugas_kuliyeah/data/local/app_database.dart';

// class LocalTaskRepository implements TaskRepository {
//   final AppDatabase db;
//   final NotificationService notificationService;

//   LocalTaskRepository(this.db, this.notificationService);

//   // --- Helper: Convert Hari ke Int untuk Notifikasi ---
//   int _getDayInt(String hari) {
//     switch (hari.toLowerCase()) {
//       case 'senin':
//         return 1;
//       case 'selasa':
//         return 2;
//       case 'rabu':
//         return 3;
//       case 'kamis':
//         return 4;
//       case 'jumat':
//         return 5;
//       case 'sabtu':
//         return 6;
//       case 'minggu':
//         return 7;
//       default:
//         return 1;
//     }
//   }

//   // --- Helper: Generate ID unik untuk Notifikasi ---
//   int _generateNotificationId(String id) {
//     return id.hashCode;
//   }

//   // ==========================================
//   // BAGIAN 1: MATA KULIAH
//   // ==========================================

//   @override
//   Future<void> addMataKuliah(core_model.MataKuliah matakuliah) async {
//     final matkulCompanion = MataKuliahsCompanion.insert(
//       id: matakuliah.id,
//       nama: matakuliah.nama,
//       dosen: matakuliah.dosen,
//       sks: matakuliah.sks,
//     );
//     await db.into(db.mataKuliahs).insert(matkulCompanion);
//   }

//   @override
//   Future<void> updateMataKuliah(core_model.MataKuliah mataKuliah) async {
//     await db
//         .update(db.mataKuliahs)
//         .replace(
//           MataKuliahsCompanion(
//             id: Value(mataKuliah.id),
//             nama: Value(mataKuliah.nama),
//             dosen: Value(mataKuliah.dosen),
//             sks: Value(mataKuliah.sks),
//           ),
//         );
//   }

//   @override
//   Future<void> deleteMataKuliah(String mataKuliahId) async {
//     // Hapus Matkul
//     await (db.delete(
//       db.mataKuliahs,
//     )..where((tbl) => tbl.id.equals(mataKuliahId))).go();
//     // Hapus Jadwal terkait
//     await (db.delete(
//       db.jadwals,
//     )..where((tbl) => tbl.mataKuliahId.equals(mataKuliahId))).go();
//     // Hapus Tugas terkait
//     await (db.delete(
//       db.tugass,
//     )..where((tbl) => tbl.mataKuliahId.equals(mataKuliahId))).go();

//     // Note: Notifikasi terkait yang dihapus tidak otomatis hilang di sini,
//     // karena ID notifikasi menggunakan hash dari ID item masing-masing.
//     // Namun itemnya sudah hilang dari database.
//   }

//   @override
//   Stream<List<core_model.MataKuliah>> watchAllMataKuliah() {
//     final streamDrift = db.select(db.mataKuliahs).watch();
//     return streamDrift.map((listMatkulDrift) {
//       return listMatkulDrift
//           .map(
//             (matkulDrift) => core_model.MataKuliah(
//               id: matkulDrift.id,
//               nama: matkulDrift.nama,
//               dosen: matkulDrift.dosen,
//               sks: matkulDrift.sks,
//             ),
//           )
//           .toList();
//     });
//   }

//   // ==========================================
//   // BAGIAN 2: JADWAL (Beserta Notifikasi)
//   // ==========================================

//   @override
//   Future<void> addJadwal(core_model.Jadwal jadwal) async {
//     // 1. Simpan ke DB
//     final jadwalCompanion = JadwalsCompanion.insert(
//       id: jadwal.id,
//       mataKuliahId: jadwal.mataKuliahId,
//       hari: jadwal.hari,
//       jamMulai: jadwal.jamMulai,
//       jamSelesai: jadwal.jamSelesai,
//       ruangan: jadwal.ruangan,
//     );
//     await db.into(db.jadwals).insert(jadwalCompanion);

//     // 2. Ambil Nama Matkul untuk judul notifikasi
//     final matkul = await (db.select(
//       db.mataKuliahs,
//     )..where((tbl) => tbl.id.equals(jadwal.mataKuliahId))).getSingle();

//     // 3. Pasang Notifikasi Mingguan
//     await notificationService.scheduleJadwalKuliah(
//       id: _generateNotificationId(jadwal.id),
//       title: "Kuliah: ${matkul.nama}",
//       body:
//           "Ruangan: ${jadwal.ruangan} | Pukul: ${jadwal.jamMulai.hour}:${jadwal.jamMulai.minute.toString().padLeft(2, '0')}",
//       dayOfWeek: _getDayInt(jadwal.hari),
//       hour: jadwal.jamMulai.hour,
//       minute: jadwal.jamMulai.minute,
//     );
//   }

//   @override
//   Future<void> updateJadwal(core_model.Jadwal jadwal) async {
//     // 1. Update DB
//     await db
//         .update(db.jadwals)
//         .replace(
//           JadwalsCompanion(
//             id: Value(jadwal.id),
//             mataKuliahId: Value(jadwal.mataKuliahId),
//             hari: Value(jadwal.hari),
//             jamMulai: Value(jadwal.jamMulai),
//             jamSelesai: Value(jadwal.jamSelesai),
//             ruangan: Value(jadwal.ruangan),
//           ),
//         );

//     // 2. Update Notifikasi
//     final matkul = await (db.select(
//       db.mataKuliahs,
//     )..where((tbl) => tbl.id.equals(jadwal.mataKuliahId))).getSingle();
//     await notificationService.scheduleJadwalKuliah(
//       id: _generateNotificationId(jadwal.id),
//       title: "Kuliah: ${matkul.nama}",
//       body:
//           "Ruangan: ${jadwal.ruangan} | Pukul: ${jadwal.jamMulai.hour}:${jadwal.jamMulai.minute.toString().padLeft(2, '0')}",
//       dayOfWeek: _getDayInt(jadwal.hari),
//       hour: jadwal.jamMulai.hour,
//       minute: jadwal.jamMulai.minute,
//     );
//   }

//   @override
//   Future<void> deleteJadwal(String jadwalId) async {
//     // Hapus DB
//     await (db.delete(db.jadwals)..where((tbl) => tbl.id.equals(jadwalId))).go();
//     // Hapus Notifikasi
//     await notificationService.cancelNotification(
//       _generateNotificationId(jadwalId),
//     );
//   }

//   @override
//   Stream<List<core_model.Jadwal>> watchJadwalByMataKuliah(String mataKuliahId) {
//     final queryStream = (db.select(
//       db.jadwals,
//     )..where((tbl) => tbl.mataKuliahId.equals(mataKuliahId))).watch();
//     return queryStream.map((listJadwalDrift) {
//       return listJadwalDrift
//           .map(
//             (jadwalDrift) => core_model.Jadwal(
//               id: jadwalDrift.id,
//               mataKuliahId: jadwalDrift.mataKuliahId,
//               hari: jadwalDrift.hari,
//               jamMulai: jadwalDrift.jamMulai,
//               jamSelesai: jadwalDrift.jamSelesai,
//               ruangan: jadwalDrift.ruangan,
//             ),
//           )
//           .toList();
//     });
//   }

//   // ==========================================
//   // BAGIAN 3: TUGAS (Beserta Notifikasi)
//   // ==========================================

//   @override
//   Future<void> addTugas(core_model.Tugas tugas) async {
//     // 1. Simpan DB
//     final tugasCompanion = TugassCompanion.insert(
//       id: tugas.id,
//       mataKuliahId: tugas.mataKuliahId,
//       jenis: tugas.jenis,
//       deskripsi: tugas.deskripsi,
//       tenggatWaktu: tugas.tenggatWaktu,
//       attachmentPath: Value(tugas.attachmentPath),
//     );
//     await db.into(db.tugass).insert(tugasCompanion);

//     // 2. Ambil Nama Matkul
//     final matkul = await (db.select(
//       db.mataKuliahs,
//     )..where((tbl) => tbl.id.equals(tugas.mataKuliahId))).getSingle();

//     // 3. Pasang Notifikasi Deadline
//     await notificationService.scheduleTugasReminder(
//       id: _generateNotificationId(tugas.id),
//       title: "${tugas.jenis}: ${matkul.nama}",
//       body: "${tugas.deskripsi} (Deadline!)",
//       scheduledDate: tugas.tenggatWaktu,
//     );
//   }

//   @override
//   Future<void> updateTugas(core_model.Tugas tugas) async {
//     // 1. Update DB
//     await db
//         .update(db.tugass)
//         .replace(
//           TugassCompanion(
//             id: Value(tugas.id),
//             mataKuliahId: Value(tugas.mataKuliahId),
//             jenis: Value(tugas.jenis),
//             deskripsi: Value(tugas.deskripsi),
//             tenggatWaktu: Value(tugas.tenggatWaktu),
//             attachmentPath: Value(tugas.attachmentPath),
//           ),
//         );

//     // 2. Update Notifikasi
//     final matkul = await (db.select(
//       db.mataKuliahs,
//     )..where((tbl) => tbl.id.equals(tugas.mataKuliahId))).getSingle();
//     await notificationService.scheduleTugasReminder(
//       id: _generateNotificationId(tugas.id),
//       title: "${tugas.jenis}: ${matkul.nama}",
//       body: "${tugas.deskripsi} (Update Deadline)",
//       scheduledDate: tugas.tenggatWaktu,
//     );
//   }

//   @override
//   Future<void> deleteTugas(String tugasId) async {
//     // Hapus DB
//     await (db.delete(db.tugass)..where((tbl) => tbl.id.equals(tugasId))).go();
//     // Hapus Notifikasi
//     await notificationService.cancelNotification(
//       _generateNotificationId(tugasId),
//     );
//   }

//   @override
//   Stream<List<core_model.Tugas>> watchTugasByMataKuliah(String mataKuliahId) {
//     final queryStream = (db.select(
//       db.tugass,
//     )..where((tbl) => tbl.mataKuliahId.equals(mataKuliahId))).watch();
//     return queryStream.map((listTugasDrift) {
//       return listTugasDrift
//           .map(
//             (tugasDrift) => core_model.Tugas(
//               id: tugasDrift.id,
//               mataKuliahId: tugasDrift.mataKuliahId,
//               jenis: tugasDrift.jenis,
//               deskripsi: tugasDrift.deskripsi,
//               tenggatWaktu: tugasDrift.tenggatWaktu,
//               attachmentPath: tugasDrift.attachmentPath,
//             ),
//           )
//           .toList();
//     });
//   }
// }
