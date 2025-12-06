import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:tugas_kuliyeah/features/tugas/inbox_shared_task_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mengambil data user dari Supabase Auth
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? "Pengguna";
    final userEmail = user?.email ?? "-";
    final userPhoto =
        user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Saya"),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // === HEADER PROFIL ===
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  backgroundImage: userPhoto != null
                      ? CachedNetworkImageProvider(userPhoto)
                      : null,
                  child: userPhoto == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white70)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userEmail,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),

          // === MENU INBOX ===
          ListTile(
            leading: const Icon(Icons.inbox, color: Colors.blueAccent),
            title: const Text("Inbox Tugas"),
            subtitle: const Text("Cek tugas yang dibagikan teman"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InboxSharedTaskScreen(),
                ),
              );
            },
          ),
          
          const Divider(),
          const SizedBox(height: 20),

          // === TOMBOL LOGOUT ===
          // Logika logout dipindahkan dari MataKuliahListScreen ke sini
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text("Logout"),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    title: const Text(
                      "Logout?",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    content: const Text(
                      "Apakah kamu yakin ingin keluar?",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Batal",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // Logika Invalidasi Provider tetap dipertahankan
                        onPressed: () async {
                          Navigator.pop(context); // Tutup Dialog
                          try {
                            // Reset semua state saat logout
                            ref.invalidate(allMataKuliahProvider);
                            ref.invalidate(jadwalByMatkulProvider);
                            ref.invalidate(tugasByMatkulProvider);
                            ref.invalidate(taskRepositoryProvider);
                            
                            await Supabase.instance.client.auth.signOut();
                            // AuthGate di main.dart akan menangani navigasi ke LoginScreen
                          } catch (e) {
                            debugPrint("Logout error: $e");
                          }
                        },
                        child: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}