// lib/core/repositories/task_repository.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart'; // butuh TimeOfDay
import 'package:tugas_kuliyeah/core/models/jadwal.dart' as core_model;
import 'package:tugas_kuliyeah/core/models/mata_kuliah.dart' as core_model;
import 'package:tugas_kuliyeah/core/models/share_tugas.dart';
import 'package:tugas_kuliyeah/core/models/task_attachment.dart';
import 'package:tugas_kuliyeah/core/models/tugas.dart' as core_model;

abstract class TaskRepository {
  // ===================== MATA KULIAH =====================
  Stream<List<core_model.MataKuliah>> watchAllMataKuliah();
  Future<void> insertMataKuliah(core_model.MataKuliah mk);
  Future<void> updateMataKuliah(core_model.MataKuliah mk);
  Future<void> deleteMataKuliah(String id);

  // ======================== JADWAL ========================
  Stream<List<core_model.Jadwal>> watchJadwalByMataKuliah(String matkulId);
  Stream<List<core_model.Jadwal>> watchAllJadwal();

  // [BARU] Menggantikan insertJadwal biasa.
  // Fungsi ini akan men-generate N baris jadwal sekaligus (Batch)
  Future<void> generateJadwalSemester({
    required String mataKuliahId,
    required DateTime tanggalMulai,
    required int jumlahPertemuan,
    required TimeOfDay jamMulai,
    required TimeOfDay jamSelesai,
    required String ruangan,
    // [BARU] Kontrol Penamaan
    required bool useAutoTitle, // True = Series, False = Custom
    required String customTitlePrefix, // Teks custom atau "Pertemuan ke-"
    required int startNumber, // Angka mulai (User defined)
  });

  // [MODIFIKASI] Update satu pertemuan spesifik (misal geser jadwal)
  Future<void> updateJadwal(core_model.Jadwal jadwal);
  
  Future<void> deleteJadwal(String id);

  // ========================= TUGAS ========================
  Stream<List<core_model.Tugas>> watchTugasByMataKuliah(String matkulId);
  Stream<List<core_model.Tugas>> watchAllTugas();

  Future<void> insertTugas(core_model.Tugas tugas);
  Future<void> updateTugas(core_model.Tugas tugas);
  Future<void> deleteTugas(String id);

  // ===================== SHARE TUGAS ======================
  Future<void> shareTugas({
    required String tugasId,
    required String receiverEmail,
  });

  Stream<List<ShareTugas>> watchSharedTasksReceived(String myUserId);
  Stream<List<ShareTugas>> watchSharedTasksSent(String myUserId);

  Future<List<Map<String, dynamic>>> getAllUsers();

  Future<String> acceptSharedTask({
    required String shareId,
    required String receiverMatkulId,
  });

  Future<void> deleteShare(String shareId);

  // ===================== ATTACHMENTS ======================
  Future<void> uploadAttachment({
    required String taskId,
    required String filePath,
  });

  Future<List<TaskAttachment>> getAttachmentsByTask(String taskId);

  Future<void> deleteAttachment(int attachmentId);

  Future<void> uploadAttachmentWeb({
    required String taskId,
    required PlatformFile file,
  });
}