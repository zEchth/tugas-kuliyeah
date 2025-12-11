import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tugas_kuliyeah/core/models/share_tugas.dart';
import 'package:tugas_kuliyeah/core/providers.dart';

class InboxSharedTaskScreen extends ConsumerWidget {
  const InboxSharedTaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxSharedTasksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text("Inbox Tugas"),
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        centerTitle: true,
      ),
      body: inbox.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e")),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                "Tidak ada tugas masuk.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final s = list[i];
              final bool isPending = s.status == "pending";
              final bool isAccepted = s.status == "accepted";

              return GestureDetector(
                onTap: () => _showActions(context, ref, s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isPending
                        ? const Color(0xFF2A0F0F) // merah gelap
                        : isAccepted
                        ? const Color(0xFF0F2A12) // hijau gelap
                        : const Color(0xFF1A1A1A), // default
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPending
                          ? Colors.redAccent
                          : isAccepted
                          ? Colors.greenAccent
                          : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.grey.shade900,
                        child: const Icon(Icons.person, color: Colors.white70),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.senderUsername ?? s.senderId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Status: ${s.status}",
                              style: TextStyle(
                                color: isPending
                                    ? Colors.redAccent
                                    : isAccepted
                                    ? Colors.greenAccent
                                    : Colors.white54,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 28,
                        color: Colors.white38,
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

  // 📌 BOTTOM SHEET DARK
  void _showActions(BuildContext context, WidgetRef ref, ShareTugas data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade900,
                  child: const Icon(Icons.school, color: Colors.white70),
                ),
                title: Text(
                  "Dari: ${data.senderUsername ?? data.senderId}",
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "Status: ${data.status}",
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 12),

              FilledButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text("Terima Tugas"),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _acceptDialog(context, ref, data);
                },
              ),

              const SizedBox(height: 10),

              OutlinedButton.icon(
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  "Hapus Riwayat",
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _deleteShare(context, ref, data);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 📌 DIALOG DARK MODE
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
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          "Pilih Mata Kuliah",
          style: TextStyle(color: Colors.white),
        ),
        content: DropdownButtonFormField<String>(
          dropdownColor: const Color(0xFF2A2A2A),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            border: const OutlineInputBorder(),
          ),
          items: userMatkul.map((mk) {
            return DropdownMenuItem(
              value: mk.id,
              child: Text(mk.nama, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (v) => selectedMatkul = v,
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text("Terima"),
            style: FilledButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              if (selectedMatkul == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pilih mata kuliah dulu.")),
                );
                return;
              }

              Navigator.pop(context);

              await ref
                  .read(taskRepositoryProvider)
                  .acceptSharedTask(
                    shareId: data.id,
                    receiverMatkulId: selectedMatkul!,
                  );
                  
              ref.read(globalRefreshProvider.notifier).state++;

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

  // 📌 DELETE DARK
  void _deleteShare(
    BuildContext context,
    WidgetRef ref,
    ShareTugas data,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          "Hapus Riwayat?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Riwayat tugas ini akan dihapus.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.read(taskRepositoryProvider).deleteShare(data.id);

    // 🔥 WAJIB: Refresh UI
    ref.invalidate(inboxSharedTasksProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Riwayat sharing dihapus.")));
    }
  }
}
