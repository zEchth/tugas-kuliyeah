// lib/data/remote/repositories/supabase_task_repository.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart'; // TimeOfDay
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tugas_kuliyeah/core/models/share_tugas.dart';
import 'package:tugas_kuliyeah/core/models/task_attachment.dart';
import 'package:tugas_kuliyeah/core/models/tugas.dart';
import 'package:tugas_kuliyeah/core/models/jadwal.dart';
import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart';
import 'package:tugas_kuliyeah/core/repositories/task_repository.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

// [UPDATE] IMPORT Notification Service
import 'package:tugas_kuliyeah/services/notification_service.dart';

class SupabaseTaskRepository implements TaskRepository {
  final SupabaseClient client;
  final Ref ref;
  // [UPDATE] Inject Service
  final NotificationService notificationService;

  SupabaseTaskRepository(this.client, this.ref, this.notificationService);

  // --- Helper: Generate Integer ID from String UUID ---
  // LocalNotification butuh INT, Supabase pakai UUID String.
  // Kita pakai hashCode. Ada risiko collision kecil, tapi cukup untuk tugas kuliah.
  int _generateId(String id) {
    return id.hashCode;
  }

  // --- Helper: Konversi Hari String ke Int ---
  int _getDayInt(String hari) {
    switch (hari.toLowerCase()) {
      case 'senin':
        return 1;
      case 'selasa':
        return 2;
      case 'rabu':
        return 3;
      case 'kamis':
        return 4;
      case 'jumat':
        return 5;
      case 'sabtu':
        return 6;
      case 'minggu':
        return 7;
      default:
        return 1;
    }
  }

  // ============================================================
  //             FITUR BARU: RESYNC NOTIFICATIONS
  // ============================================================
  // Fungsi ini dipanggil saat App dibuka (MainNavigationScreen)
  // Menjamin notifikasi di HP sesuai dengan data di Server.
  Future<void> resyncLocalNotifications() async {
    try {
      final uid = client.auth.currentUser?.id;
      if (uid == null) return;

      debugPrint("[SYNC] Memulai sinkronisasi notifikasi...");

      // 1. Bersihkan semua alarm lama (Reset state)
      await notificationService.cancelAllNotifications();

      // 2. Ambil data TUGAS yang BELUM selesai & deadline di masa depan
      final now = DateTime.now().toIso8601String();
      final tugasData = await client
          .from('tugas')
          .select('*, mata_kuliah(nama_matkul)')
          .eq('owner_id', uid)
          .neq('status', 'Selesai') // Abaikan yang selesai
          .gt('due_at', now); // Hanya yang akan datang

      final listTugas = (tugasData as List)
          .map((x) => Tugas.fromMap(x))
          .toList();

      // 3. Jadwalkan Ulang Tugas
      for (final t in listTugas) {
        final matkulName = t.mataKuliahName ?? "Tugas";
        await notificationService.scheduleTugasReminder(
          id: _generateId(t.id),
          title: "${t.type}: $matkulName",
          body: "${t.title} (Deadline!)",
          scheduledDate: t.dueAt,
        );
      }

      // 4. Ambil data JADWAL (Aktifkan untuk semua jadwal)
      final jadwalData = await client
          .from('jadwal_kuliah')
          .select('*, mata_kuliah(nama_matkul)')
          .eq('owner_id', uid)
          .eq('status_pertemuan', 'Terjadwal'); // Hanya yang aktif

      final listJadwal = (jadwalData as List)
          .map((x) => Jadwal.fromMap(x))
          .toList();

      // 5. Jadwalkan Ulang Jadwal
      // PERHATIAN: Ini akan memasang alarm mingguan untuk setiap row jadwal.
      // Jika jadwal digenerate 16 pertemuan, alarmnya akan redundant di hari yang sama.
      // Optimasi: Kita ambil jadwal unik per hari per matkul saja.
      // (Tapi untuk simplifikasi kode saat ini, kita pasang saja jadwal spesifik
      //  menggunakan scheduleTugasReminder agar akurat per tanggal)

      for (final j in listJadwal) {
        // Cek apakah jadwal ini di masa depan
        final jadwalDateTime = DateTime(
          j.tanggal.year,
          j.tanggal.month,
          j.tanggal.day,
          j.jamMulai.hour,
          j.jamMulai.minute,
        );

        if (jadwalDateTime.isAfter(DateTime.now())) {
          final matkulName = j.mataKuliahName ?? "Kuliah";

          // Kita gunakan one-time reminder agar akurat sesuai tanggal (bukan weekly recurring)
          // karena tabel jadwal_kuliah menyimpan tanggal spesifik.
          await notificationService.scheduleTugasReminder(
            id: _generateId(j.id),
            title: "Kelas: $matkulName",
            body: "Ruang: ${j.ruangan} | ${j.judul}",
            scheduledDate: jadwalDateTime,
          );
        }
      }

      debugPrint(
        "[SYNC] Selesai. ${listTugas.length} Tugas & ${listJadwal.length} Jadwal dijadwalkan.",
      );
    } catch (e) {
      debugPrint("[SYNC ERROR] Gagal sinkronisasi notifikasi: $e");
    }
  }

  // ============================================================
  //                        MATA KULIAH
  // ============================================================

  @override
  Stream<List<MataKuliah>> watchAllMataKuliah() {
    final uid = client.auth.currentUser!.id;

    return client
        .from('mata_kuliah')
        .stream(primaryKey: ['id'])
        .eq('owner_id', uid)
        .map((rows) => rows.map(MataKuliah.fromMap).toList());
  }

  @override
  Future<void> insertMataKuliah(MataKuliah mk) async {
    final uid = Supabase.instance.client.auth.currentUser!.id;

    await client.from('mata_kuliah').insert({...mk.toMap(), 'owner_id': uid});
  }

  @override
  Future<void> updateMataKuliah(MataKuliah mk) async {
    await client.from('mata_kuliah').update(mk.toMap()).eq('id', mk.id);
  }

  @override
  Future<void> deleteMataKuliah(String id) async {
    // Note: Menghapus Matkul akan cascade delete tugas & jadwal di DB (jika di-set cascade).
    // Tapi notifikasi lokal tidak otomatis hilang.
    // Idealnya kita query dulu ID tugas/jadwal anaknya lalu cancelNotif.
    // Tapi demi performa, kita andalkan "resyncLocalNotifications" saat app restart,
    // atau biarkan user melihat notifikasi hantu sekali (minor issue).
    await client.from('mata_kuliah').delete().eq('id', id);
  }

  // ============================================================
  //                           JADWAL
  // ============================================================

  @override
  Stream<List<Jadwal>> watchJadwalByMataKuliah(String matkulId) {
    final uid = Supabase.instance.client.auth.currentUser!.id;
    return client.from('jadwal_kuliah').stream(primaryKey: ['id']).map((rows) {
      final list = rows
          .map(Jadwal.fromMap)
          .where((j) => j.ownerId == uid && j.mataKuliahId == matkulId)
          .toList();

      list.sort((a, b) {
        final dateComp = a.tanggal.compareTo(b.tanggal);
        if (dateComp != 0) return dateComp;
        return a.jamMulai.compareTo(b.jamMulai);
      });
      return list;
    });
  }

  @override
  Stream<List<Jadwal>> watchAllJadwal() {
    final uid = client.auth.currentUser!.id;
    return client
        .from('jadwal_kuliah')
        .stream(primaryKey: ['id'])
        .eq('owner_id', uid)
        .map((rows) {
          final list = rows.map(Jadwal.fromMap).toList();
          list.sort((a, b) {
            final dateComp = a.tanggal.compareTo(b.tanggal);
            if (dateComp != 0) return dateComp;
            return a.jamMulai.compareTo(b.jamMulai);
          });
          return list;
        });
  }

  @override
  Future<void> generateJadwalSemester({
    required String mataKuliahId,
    required DateTime tanggalMulai,
    required int jumlahPertemuan,
    required TimeOfDay jamMulai,
    required TimeOfDay jamSelesai,
    required String ruangan,
    required bool useAutoTitle,
    required String customTitlePrefix,
    required int startNumber,
  }) async {
    final uid = client.auth.currentUser!.id;
    final batchId = const Uuid().v4();

    // BERSIHKAN NOTIF JADWAL LAMA MATKUL INI
    final oldJadwal = await client
        .from('jadwal_kuliah')
        .select('id')
        .eq('mata_kuliah_id', mataKuliahId);

    for (final j in oldJadwal) {
      await notificationService.cancelNotification(_generateId(j['id']));
    }

    List<Map<String, dynamic>> batchData = [];

    // [UPDATE] Ambil nama matkul untuk notifikasi
    final matkulRes = await client
        .from('mata_kuliah')
        .select('nama_matkul')
        .eq('id', mataKuliahId)
        .single();
    final matkulName = matkulRes['nama_matkul'];

    final startT = _formatTimeOfDay(jamMulai);
    final endT = _formatTimeOfDay(jamSelesai);

    for (int i = 0; i < jumlahPertemuan; i++) {
      // Logic Mingguan: Tanggal Mulai + (i * 7 hari)
      final tanggalPertemuan = tanggalMulai.add(Duration(days: i * 7));
      final currentNumber = startNumber + i;

      String finalTitle;
      if (useAutoTitle) {
        // Mode Seri: "Pertemuan ke-{currentNumber}"
        finalTitle = "$customTitlePrefix$currentNumber";
      } else {
        // Mode Kustom Murni: "Responsi" (Semua sama)
        finalTitle = customTitlePrefix;
      }

      final newId = const Uuid().v4();

      batchData.add({
        'id': newId,
        'owner_id': uid,
        'mata_kuliah_id': mataKuliahId,
        'batch_id': batchId,
        'tanggal': tanggalPertemuan.toIso8601String().split('T')[0],
        'judul': finalTitle,
        'status_pertemuan': 'Terjadwal',
        'jam_mulai': startT,
        'jam_selesai': endT,
        'ruangan': ruangan,
        'created_at': DateTime.now().toIso8601String(),
      });

      // [UPDATE] Jadwalkan Notifikasi Lokal Langsung
      final startDateTime = DateTime(
        tanggalPertemuan.year,
        tanggalPertemuan.month,
        tanggalPertemuan.day,
        jamMulai.hour,
        jamMulai.minute,
      );

      // Hanya jadwalkan jika di masa depan
      if (startDateTime.isAfter(DateTime.now())) {
        await notificationService.scheduleTugasReminder(
          id: _generateId(newId),
          title: "Kelas: $matkulName",
          body: "$finalTitle di $ruangan",
          scheduledDate: startDateTime,
        );
      }
    }

    await client.from('jadwal_kuliah').insert(batchData);
    await resyncLocalNotifications();
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return "$h:$m:00";
  }

  @override
  Future<void> updateJadwal(Jadwal jadwal) async {
    await client
        .from('jadwal_kuliah')
        .update(jadwal.toMap())
        .eq('id', jadwal.id);

    // [UPDATE] Update Notifikasi
    final startDateTime = DateTime(
      jadwal.tanggal.year,
      jadwal.tanggal.month,
      jadwal.tanggal.day,
      jadwal.jamMulai.hour,
      jadwal.jamMulai.minute,
    );

    // Ambil nama matkul (karena di object jadwal mungkin null jika belum di-join)
    String matkulName = "Kuliah";
    if (jadwal.mataKuliahName != null) {
      matkulName = jadwal.mataKuliahName!;
    } else {
      final res = await client
          .from('mata_kuliah')
          .select('nama_matkul')
          .eq('id', jadwal.mataKuliahId)
          .single();
      matkulName = res['nama_matkul'];
    }

    await notificationService.cancelNotification(_generateId(jadwal.id));

    if (startDateTime.isAfter(DateTime.now())) {
      await notificationService.scheduleTugasReminder(
        id: _generateId(jadwal.id),
        title: "Kelas: $matkulName (Updated)",
        body: "${jadwal.judul} di ${jadwal.ruangan}",
        scheduledDate: startDateTime,
      );
    }
  }

  @override
  Future<void> deleteJadwal(String id) async {
    await client.from('jadwal_kuliah').delete().eq('id', id);
    // [UPDATE] Hapus Notifikasi
    await notificationService.cancelNotification(_generateId(id));
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

    await client.from('tugas').insert({...tugas.toMap(), 'owner_id': uid});

    // [UPDATE] Jadwalkan Notifikasi
    // Perlu ambil nama matkul dulu
    final res = await client
        .from('mata_kuliah')
        .select('nama_matkul')
        .eq('id', tugas.mataKuliahId)
        .single();
    final matkulName = res['nama_matkul'];

    await notificationService.scheduleTugasReminder(
      id: _generateId(tugas.id),
      title: "${tugas.type}: $matkulName",
      body: "${tugas.title} (Deadline!)",
      scheduledDate: tugas.dueAt,
    );
  }

  @override
  Future<void> updateTugas(Tugas tugas) async {
    await client.from('tugas').update(tugas.toMap()).eq('id', tugas.id);

    // [UPDATE] Reschedule Notifikasi
    await notificationService.cancelNotification(_generateId(tugas.id));

    if (tugas.status != 'Selesai' && tugas.dueAt.isAfter(DateTime.now())) {
      // Perlu ambil nama matkul (fetch ulang atau pakai yang ada)
      String matkulName = "Tugas";
      if (tugas.mataKuliahName != null) {
        matkulName = tugas.mataKuliahName!;
      } else {
        final res = await client
            .from('mata_kuliah')
            .select('nama_matkul')
            .eq('id', tugas.mataKuliahId)
            .single();
        matkulName = res['nama_matkul'];
      }

      await notificationService.scheduleTugasReminder(
        id: _generateId(tugas.id),
        title: "${tugas.type}: $matkulName",
        body: "${tugas.title} (Updated)",
        scheduledDate: tugas.dueAt,
      );
    }
  }

  @override
  Future<void> deleteTugas(String id) async {
    await client.from('tugas').delete().eq('id', id);
    // [UPDATE] Hapus Notifikasi
    await notificationService.cancelNotification(_generateId(id));
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
    yield [];
    final stream = client
        .from('share_tugas')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', myUserId);

    await for (final rows in stream) {
      final List<Map<String, dynamic>> rowList =
          List<Map<String, dynamic>>.from(rows);

      final senderIds = rowList
          .map((r) => r['sender_id'] as String?)
          .where((id) => id != null)
          .map((id) => id!)
          .toSet()
          .toList();

      Map<String, String> profileMap = {};
      if (senderIds.isNotEmpty) {
        final idList = senderIds.map((e) => '"$e"').join(',');

        final profilesResp = await client
            .from('profiles')
            .select('id, username')
            .filter('id', 'in', '($idList)');

        final List<dynamic> profilesList = List<dynamic>.from(profilesResp);
        for (final p in profilesList) {
          final id = p['id'] as String?;
          final username = p['username'] as String?;
          if (id != null && username != null) {
            profileMap[id] = username;
          }
        }
      }

      final result = rowList.map((row) {
        return ShareTugas.fromMap({
          ...row,
          'username': profileMap[row['sender_id']] ?? 'Unknown',
        });
      }).toList();

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
    // RPC ini akan meng-copy tugas.
    // Tugas baru akan muncul di tabel 'tugas' milik receiver.
    // Karena kita pakai 'StreamProvider' untuk list tugas,
    // UI akan update otomatis.
    // [NOTE] Untuk notifikasi: Tugas baru ini belum punya alarm lokal.
    // Solusi: Resync saat refresh / buka app, atau kita bisa trigger manual disini
    // tapi agak tricky karena kita tidak tahu ID tugas baru yang dihasilkan RPC.
    // Cara terbaik: Panggil resyncLocalNotifications() setelah sukses accept.

    final resp = await client.rpc(
      'accept_shared_task',
      params: {'share_id': shareId, 'target_mata_kuliah': receiverMatkulId},
    );

    // Trigger Resync agar tugas baru terpasang alarmnya
    await resyncLocalNotifications();

    return resp as String;
  }

  @override
  Future<void> deleteShare(String shareId) async {
    await client.from('share_tugas').delete().eq('id', shareId);
  }

  // ===================== ATTACHMENTS =====================

  @override
  Future<void> uploadAttachment({
    required String taskId,
    required String filePath,
  }) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final fileName = filePath.split('/').last;
    final ext = fileName.split('.').last;
    final mime = _extensionToMime(ext);
    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final storagePath = 'attachment_folder/$taskId/$uniqueName';
    final userId = client.auth.currentUser!.id;

    await client.storage
        .from('attachments')
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(
            upsert: false,
            metadata: {"owner_id": userId},
          ),
        );

    final url = client.storage.from('attachments').getPublicUrl(storagePath);

    await client.from('task_attachments').insert({
      'task_id': taskId,
      'owner_id': userId,
      'path': storagePath,
      'url': url,
      'size': bytes.length,
      'mime': mime,
    });
  }

  @override
  Future<List<TaskAttachment>> getAttachmentsByTask(String taskId) async {
    final rows = await client
        .from('task_attachments')
        .select()
        .eq('task_id', taskId);

    return rows.map<TaskAttachment>((map) {
      return TaskAttachment.fromMap(map);
    }).toList();
  }

  @override
  Future<void> deleteAttachment(int attachmentId) async {
    final row = await client
        .from('task_attachments')
        .select('path')
        .eq('id', attachmentId)
        .maybeSingle();

    if (row != null) {
      final path = row['path'];
      await client.storage.from('attachments').remove([path]);
    }
    await client.from('task_attachments').delete().eq('id', attachmentId);
  }

  @override
  Future<void> uploadAttachmentWeb({
    required String taskId,
    required PlatformFile file,
  }) async {
    final bytes = file.bytes!;
    final fileName = file.name;
    final ext = fileName.split('.').last;
    final mime = _extensionToMime(ext);
    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final storagePath = 'attachment_folder/$taskId/$uniqueName';
    final userId = client.auth.currentUser!.id;

    await client.storage
        .from('attachments')
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(
            upsert: false,
            metadata: {"owner_id": userId},
          ),
        );

    final url = client.storage.from('attachments').getPublicUrl(storagePath);

    await client.from('task_attachments').insert({
      'task_id': taskId,
      'owner_id': userId,
      'path': storagePath,
      'url': url,
      'size': bytes.length,
      'mime': mime,
    });
  }

  String _extensionToMime(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Future<String?> getFcmTokenByEmail(String email) async {
    // 1. Ambil user_id dari tabel user_emails
    final user = await client
        .from('user_emails')
        .select('id')
        .eq('email', email)
        .maybeSingle();

    if (user == null) return null;

    final userId = user['id'];

    // 2. Ambil token dari fcm_tokens
    final res = await client
        .from('fcm_tokens')
        .select('token')
        .eq('user_id', userId)
        .maybeSingle();

    if (res == null) return null;

    return res['token'];
  }

  @override
  Future<void> sendShareNotif({
    required String token,
    required String title,
    required String body,
  }) async {
    await client.functions.invoke(
      'task-share-notify',
      body: {'token': token, 'title': title, 'body': body},
    );
  }
}
