import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kuliyeah/core/repositories/task_repository.dart';
import 'package:tugas_kuliyeah/data/local/app_database.dart';
import 'package:tugas_kuliyeah/data/repositories/local_task_repository.dart';
// IMPORT SERVICE
import 'package:tugas_kuliyeah/services/notification_service.dart';

import 'package:tugas_kuliyeah/core/models/jadwal.dart' as core_model;
import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart' as core_model;
import 'package:tugas_kuliyeah/core/models/tugas.dart' as core_model;

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Provider untuk Notification Service (di-override di main.dart nanti)
final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final db = ref.watch(databaseProvider);
  // AMBIL SERVICE DARI PROVIDER
  final notifService = ref.watch(notificationServiceProvider);

  // MASUKKAN KE REPOSITORY
  return LocalTaskRepository(db, notifService);
});

// ... existing code ... (sisanya sama)
final allMataKuliahProvider = StreamProvider<List<core_model.MataKuliah>>((
  ref,
) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchAllMataKuliah();
});

final jadwalByMatkulProvider =
    StreamProvider.family<List<core_model.Jadwal>, String>((ref, mataKuliahId) {
      final repository = ref.watch(taskRepositoryProvider);
      return repository.watchJadwalByMataKuliah(mataKuliahId);
    });

final tugasByMatkulProvider =
    StreamProvider.family<List<core_model.Tugas>, String>((ref, mataKuliahId) {
      final repository = ref.watch(taskRepositoryProvider);
      return repository.watchTugasByMataKuliah(mataKuliahId);
    });
