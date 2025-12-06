import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tugas_kuliyeah/core/models/share_tugas.dart';
import 'package:tugas_kuliyeah/core/models/tugas.dart';
import 'package:tugas_kuliyeah/core/models/jadwal.dart';
import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart';
import 'package:tugas_kuliyeah/core/repositories/task_repository.dart';

class SupabaseTaskRepository implements TaskRepository {
  final SupabaseClient client;

  SupabaseTaskRepository(this.client);

  // ============================================================
  //                        MATA KULIAH
  // ============================================================

  @override
  Stream<List<MataKuliah>> watchAllMataKuliah() {
    final uid = Supabase.instance.client.auth.currentUser!.id;

    return client
        .from('mata_kuliah')
        .stream(primaryKey: ['id'])
        .eq('owner_id', uid) // WAJIB
        .map((rows) => rows.map(MataKuliah.fromMap).toList());
  }

  @override
  Future<void> insertMataKuliah(MataKuliah mk) async {
    final uid = Supabase.instance.client.auth.currentUser!.id;

    await client.from('mata_kuliah').insert({
      ...mk.toMap(),
      'owner_id': uid, // override
    });
  }

  @override
  Future<void> updateMataKuliah(MataKuliah mk) async {
    await client.from('mata_kuliah').update(mk.toMap()).eq('id', mk.id);
  }

  @override
  Future<void> deleteMataKuliah(String id) async {
    await client.from('mata_kuliah').delete().eq('id', id);
  }

  // ============================================================
  //                           JADWAL
  // ============================================================

  @override
  Stream<List<Jadwal>> watchJadwalByMataKuliah(String matkulId) {
    final uid = Supabase.instance.client.auth.currentUser!.id;
    return client.from('jadwal_kuliah').stream(primaryKey: ['id'])
    // .eq('mata_kuliah_id', matkulId)
    // .eq('owner_id', uid)
    .map((rows) {
      return rows
          .map(Jadwal.fromMap)
          .where((j) => j.ownerId == uid && j.mataKuliahId == matkulId)
          .toList();
    });
  }

  // [BARU] Mengambil SEMUA jadwal user (tanpa filter matkul)
  @override
  Stream<List<Jadwal>> watchAllJadwal() {
    final uid = Supabase.instance.client.auth.currentUser!.id;
    return client
        .from('jadwal_kuliah')
        .stream(primaryKey: ['id'])
        .eq('owner_id', uid)
        .map((rows) => rows.map(Jadwal.fromMap).toList());
  }

  @override
  Future<void> insertJadwal(Jadwal jadwal) async {
    final uid = Supabase.instance.client.auth.currentUser!.id;

    await client.from('jadwal_kuliah').insert({
      ...jadwal.toMap(),
      'owner_id': uid,
    });
  }

  @override
  Future<void> updateJadwal(Jadwal jadwal) async {
    await client
        .from('jadwal_kuliah')
        .update(jadwal.toMap())
        .eq('id', jadwal.id);
  }

  @override
  Future<void> deleteJadwal(String id) async {
    await client.from('jadwal_kuliah').delete().eq('id', id);
  }

  // ============================================================
  //                            TUGAS
  // ============================================================

  @override
  Stream<List<Tugas>> watchTugasByMataKuliah(String matkulId) {
    return client
        .from('tugas')
        .stream(primaryKey: ['id'])
        .eq('mata_kuliah_id', matkulId)
        .map((rows) => rows.map(Tugas.fromMap).toList());
  }
  
  // [BARU] Mengambil SEMUA tugas user
  @override
  Stream<List<Tugas>> watchAllTugas() {
    final uid = Supabase.instance.client.auth.currentUser!.id;
    return client
        .from('tugas')
        .stream(primaryKey: ['id'])
        .eq('owner_id', uid)
        .map((rows) => rows.map(Tugas.fromMap).toList());
  }

  @override
  Future<void> insertTugas(Tugas tugas) async {
    final uid = Supabase.instance.client.auth.currentUser!.id;

    await client.from('tugas').insert({
      ...tugas.toMap(),
      'owner_id': uid, // override
    });
  }

  @override
  Future<void> updateTugas(Tugas tugas) async {
    await client.from('tugas').update(tugas.toMap()).eq('id', tugas.id);
  }

  @override
  Future<void> deleteTugas(String id) async {
    await client.from('tugas').delete().eq('id', id);
  }

  // ============================================================
  //                         SHARE TUGAS
  // ============================================================

  @override
  Future<void> shareTugas({
    required String tugasId,
    required String receiverEmail,
  }) async {
    final user = await client
        .from('user_emails')
        .select('id')
        .eq('email', receiverEmail)
        .maybeSingle();

    if (user == null) {
      throw Exception("User tidak ditemukan");
    }

    await client.from('share_tugas').insert({
      'task_id': tugasId,
      'sender_id': client.auth.currentUser!.id,
      'receiver_id': user['id'],
    });
  }

  @override
  Stream<List<ShareTugas>> watchSharedTasksReceived(String myUserId) async* {
    final stream = client
        .from('share_tugas')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', myUserId);

    await for (final rows in stream) {
      final List<ShareTugas> result = [];

      for (final row in rows) {
        // 🔥 Ambil nama pengirim dari tabel profiles
        final profile = await client
            .from('profiles')
            .select('username')
            .eq('id', row['sender_id'])
            .maybeSingle();

        result.add(
          ShareTugas.fromMap({
            ...row,
            'username': profile?['username'] ?? profile?['data']?['username'],

          }),
        );
      }

      yield result;
    }
  }

  @override
  Stream<List<ShareTugas>> watchSharedTasksSent(String myUserId) {
    return client
        .from('share_tugas')
        .stream(primaryKey: ['id'])
        .eq('sender_id', myUserId)
        .map((rows) => rows.map(ShareTugas.fromMap).toList());
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final rows = await client
        .from('user_emails')
        .select('id, email')
        .order('email');

    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<String> acceptSharedTask({
    required String shareId,
    required String receiverMatkulId,
  }) async {
    final resp = await client.rpc(
      'accept_shared_task',
      params: {'share_id': shareId, 'target_mata_kuliah': receiverMatkulId},
    );

    return resp as String;
  }
}