// lib/data/local/app_database.native.dart (Ganti nama app_database.dart yang lama)

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
// ... (sisa import)

// Ini adalah fungsi koneksi untuk Native
DatabaseConnection connect() {
  return DatabaseConnection.delayed(Future(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    final connection = NativeDatabase(file);
    return connection as DatabaseConnection; // Type casting eksplisit
  }));
}