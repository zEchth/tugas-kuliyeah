import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tugas_kuliyeah/core/models/task_attachment.dart';
import 'package:tugas_kuliyeah/core/repositories/task_repository.dart';
import 'package:tugas_kuliyeah/data/local/app_database.dart';
import 'package:tugas_kuliyeah/core/models/share_tugas.dart';

// import 'package:tugas_kuliyeah/data/repositories/local_task_repository.dart';

// tambahan
import 'package:tugas_kuliyeah/data/remote/repositories/supabase_task_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// IMPORT SERVICE
import 'package:tugas_kuliyeah/services/notification_service.dart';

import 'package:tugas_kuliyeah/core/models/jadwal.dart' as core_model;
import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart' as core_model;
import 'package:tugas_kuliyeah/core/models/tugas.dart' as core_model;

final globalRefreshProvider = StateProvider<int>((ref) => 0);

final authStateProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (data) => data.session?.user,
  );
});

final userProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Provider untuk Notification Service (di-override di main.dart nanti)
final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  // final db = ref.watch(databaseProvider);

  // AMBIL SERVICE DARI PROVIDER
  // final notifService = ref.read(notificationServiceProvider);

  // MASUKKAN KE REPOSITORY
  // return LocalTaskRepository(db, notifService);
  return SupabaseTaskRepository(Supabase.instance.client, ref);
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
      ref.watch(globalRefreshProvider); 
      final repository = ref.watch(taskRepositoryProvider);
      return repository.watchJadwalByMataKuliah(mataKuliahId);
    });

final tugasByMatkulProvider =
    StreamProvider.family<List<core_model.Tugas>, String>((ref, mataKuliahId) {
      ref.watch(globalRefreshProvider);   
      final repository = ref.watch(taskRepositoryProvider);
      return repository.watchTugasByMataKuliah(mataKuliahId);
    });

final allUsersProvider = FutureProvider((ref) async {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getAllUsers();
});

final inboxSharedTasksProvider = StreamProvider<List<ShareTugas>>((ref) {
  ref.watch(globalRefreshProvider); 
  final auth = ref.watch(authStateProvider);

  return auth.when(
    data: (user) {
      if (user == null) {
        return Stream.value([]); // user belum login
      }

      return ref
          .watch(taskRepositoryProvider)
          .watchSharedTasksReceived(user.id);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// [SOLUSI v3.0] Menggunakan Notifier API (pengganti StateProvider Legacy)
// Class ini menangani logic penambahan dan penghapusan ID sementara
class TempDeletedItemsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    // Initial state adalah Set kosong
    return const {};
  }

  // Method untuk menambah ID ke dalam ignore list
  void add(String id) {
    state = {...state, id};
  }

  // Method untuk menghapus ID dari ignore list (rollback)
  void remove(String id) {
    state = {...state}..remove(id);
  }
}

// Definisikan Provider menggunakan NotifierProvider

// 1. Untuk Jadwal
final tempDeletedJadwalProvider =
    NotifierProvider<TempDeletedItemsNotifier, Set<String>>(
      TempDeletedItemsNotifier.new,
    );

// 2. Untuk Tugas
final tempDeletedTugasProvider =
    NotifierProvider<TempDeletedItemsNotifier, Set<String>>(
      TempDeletedItemsNotifier.new,
    );

// 3. Untuk Mata Kuliah (BARU)
final tempDeletedMataKuliahProvider =
    NotifierProvider<TempDeletedItemsNotifier, Set<String>>(
      TempDeletedItemsNotifier.new,
    );

// ==============================================================
//           PROVIDERS KHUSUS HOME SCREEN (DASHBOARD)
// ==============================================================

// 1. Stream RAW dari Repository
final allTugasRawProvider = StreamProvider<List<core_model.Tugas>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAllTugas();
});

final allJadwalRawProvider = StreamProvider<List<core_model.Jadwal>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAllJadwal();
});

// 2. Provider "Pintar" yang menggabungkan (JOIN) data Matkul ke Tugas
// agar kita bisa menampilkan "Nama Matkul" di Home Screen.
final allTugasLengkapProvider = Provider<AsyncValue<List<core_model.Tugas>>>((
  ref,
) {
  final tugasAsync = ref.watch(allTugasRawProvider);
  final matkulAsync = ref.watch(allMataKuliahProvider);

  if (tugasAsync.isLoading || matkulAsync.isLoading) {
    return const AsyncLoading();
  }

  if (tugasAsync.hasError) {
    return AsyncError(tugasAsync.error!, tugasAsync.stackTrace!);
  }
  if (matkulAsync.hasError) {
    return AsyncError(matkulAsync.error!, matkulAsync.stackTrace!);
  }

  final listTugas = tugasAsync.value ?? [];
  final listMatkul = matkulAsync.value ?? [];

  // Client-Side JOIN
  final joined = listTugas.map((tugas) {
    // Cari nama matkul berdasarkan ID
    final mk = listMatkul.where((m) => m.id == tugas.mataKuliahId).firstOrNull;
    return tugas.copyWith(mataKuliahName: mk?.nama ?? "Matkul Dihapus");
  }).toList();

  return AsyncData(joined);
});

// 3. Provider "Pintar" untuk Jadwal Lengkap
final allJadwalLengkapProvider = Provider<AsyncValue<List<core_model.Jadwal>>>((
  ref,
) {
  final jadwalAsync = ref.watch(allJadwalRawProvider);
  final matkulAsync = ref.watch(allMataKuliahProvider);

  if (jadwalAsync.isLoading || matkulAsync.isLoading) {
    return const AsyncLoading();
  }

  if (jadwalAsync.hasError) {
    return AsyncError(jadwalAsync.error!, jadwalAsync.stackTrace!);
  }
  if (matkulAsync.hasError) {
    return AsyncError(matkulAsync.error!, matkulAsync.stackTrace!);
  }

  final listJadwal = jadwalAsync.value ?? [];
  final listMatkul = matkulAsync.value ?? [];

  // Client-Side JOIN
  final joined = listJadwal.map((jadwal) {
    final mk = listMatkul.where((m) => m.id == jadwal.mataKuliahId).firstOrNull;
    return jadwal.copyWith(mataKuliahName: mk?.nama ?? "Matkul Dihapus");
  }).toList();

  return AsyncData(joined);
});

// Atachmen
final attachmentsByTaskProvider =
    StreamProvider.family<List<TaskAttachment>, String>((ref, taskId) {
      ref.watch(globalRefreshProvider); 
      final repo = ref.watch(taskRepositoryProvider);

      return Supabase.instance.client
          .from('task_attachments')
          .stream(primaryKey: ['id'])
          .eq('task_id', taskId)
          .map((rows) => rows.map(TaskAttachment.fromMap).toList());
    });
