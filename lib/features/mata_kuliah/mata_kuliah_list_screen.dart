// lib/features/mata_kuliah/mata_kuliah_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/add_edit_mata_kuliah_screen.dart';
import 'package:tugas_kuliyeah/features/mata_kuliah/mata_kuliah_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MataKuliahListScreen extends ConsumerWidget {
  const MataKuliahListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 'watch' stream provider-nya.
    final asyncMataKuliah = ref.watch(allMataKuliahProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Mata Kuliah Saya"),
        
        // alfath: menambahkan tombol logout
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],

      ),
      body: asyncMataKuliah.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (listMataKuliah) {
          if (listMataKuliah.isEmpty) {
            return Center(
              child: Text(
                "Belum ada mata kuliah.\nTekan (+) untuk menambah.",
                textAlign: TextAlign.center,
                ),
            );
          }

          return ListView.builder(
            itemCount: listMataKuliah.length,
            itemBuilder: (context, index) {
              final matkul = listMataKuliah[index];
              
              // --- Delete (Geser) ---
              return Dismissible(
                key: ValueKey(matkul.id), // Kunci unik
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  // Panggil fungsi Delete dari repository
                  ref.read(taskRepositoryProvider).deleteMataKuliah(matkul.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${matkul.nama} dihapus")));
                },
                child: ListTile(
                  title: Text(matkul.nama),
                  subtitle: Text("${matkul.dosen} - ${matkul.sks} SKS"),
                  trailing: Icon(Icons.chevron_right),
                  
                  // --- Read (Detail) ---
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MataKuliahDetailScreen(matkul: matkul),
                      ),
                    );
                  },

                  // --- Update (Tahan Lama) ---
                  onLongPress: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Kirim matkul untuk mode Edit
                        builder: (context) => AddEditMataKuliahScreen(matkul: matkul),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      // --- Create ---
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Jangan kirim matkul untuk mode Add
              builder: (context) => AddEditMataKuliahScreen(),
            ),
          );
        },
      ),
    );
  }
}