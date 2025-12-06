// 📌 IMPORT YANG BENAR
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tugas_kuliyeah/core/models/share_tugas.dart';
import 'package:tugas_kuliyeah/core/providers.dart';
// import 'package:tugas_kuliyeah/core/repositories/task_repository.dart';

class InboxSharedTaskScreen extends ConsumerWidget {
  const InboxSharedTaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxSharedTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Inbox Tugas")),
      body: inbox.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e")),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text("Tidak ada tugas masuk."));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final s = list[i];

              return Card(
                child: ListTile(
                  title: Text("Dari: ${s.senderUsername ?? s.senderId}"),
                  subtitle: Text("Status: ${s.status}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _acceptDialog(context, ref, s);
                        },
                        child: const Text("Terima"),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteShare(context, ref, s);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 📌 DIALOG TERIMA & PILIH MATA KULIAH TUJUAN
  void _acceptDialog(
    BuildContext context,
    WidgetRef ref,
    ShareTugas data,
  ) async {
    final userMatkul = await ref.read(allMataKuliahProvider.future);

    String? selectedMatkul;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pilih Mata Kuliah"),
        content: DropdownButtonFormField<String>(
          items: userMatkul.map((mk) {
            return DropdownMenuItem(value: mk.id, child: Text(mk.nama));
          }).toList(),
          onChanged: (v) => selectedMatkul = v,
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Terima"),
            onPressed: () async {
              if (selectedMatkul == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pilih mata kuliah dulu.")),
                );
                return; // STOP, jangan lanjut accept
              }
              Navigator.pop(context);

              // 🔥 Terima dan clone tugas
              await ref
                  .read(taskRepositoryProvider)
                  .acceptSharedTask(
                    shareId: data.id,
                    receiverMatkulId: selectedMatkul!,
                  );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tugas berhasil diambil.")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _deleteShare(
    BuildContext context,
    WidgetRef ref,
    ShareTugas data,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Riwayat?"),
        content: const Text("Riwayat tugas yang dibagikan ini akan dihapus."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.read(taskRepositoryProvider).deleteShare(data.id);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Riwayat sharing dihapus.")));
    }
  }
}
