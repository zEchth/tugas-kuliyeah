// lib/core/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kuliyeah/core/repositories/task_repository.dart';
import 'package:tugas_kuliyeah/data/local/app_database.dart';
import 'package:tugas_kuliyeah/data/repositories/local_task_repository.dart';

import 'package:tugas_kuliyeah/core/models/jadwal.dart' as core_model;
import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart' as core_model;
// import juga remote repository nanti

// Provider untuk Database Lokal
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Provider untuk Repository (KUNCI FLEKSIBILITAS)
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final db = ref.watch(databaseProvider);

  // Kunci fleksibilitas
  // Kembalikan implementasi LOKAL
  return LocalTaskRepository(db);

  // Nanti, jika user login cloud:
  // if (user.isLoggedIn) {
  //   return RemoteTaskRepository(apiClient);
  // } else {
  //   return LocalTaskRepository(db);
  // }
});

// Provider ini untuk MENGAMATI DAFTAR Mata Kuliah
final allMataKuliahProvider =
    StreamProvider<List<core_model.MataKuliah>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchAllMataKuliah();
});

// Provider untuk MENGAMATI JADWAL dari ID Matkul tertentu
final jadwalByMatkulProvider =
    StreamProvider.family<List<core_model.Jadwal>, String>((ref, mataKuliahId) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchJadwalByMataKuliah(mataKuliahId);
});