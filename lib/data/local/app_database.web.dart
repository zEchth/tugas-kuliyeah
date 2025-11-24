// lib/data/local/app_database.web.dart

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart'; // atau drift/web.dart (tergantung versi)

DatabaseConnection connect() {
  return DatabaseConnection.delayed(Future(() async {
    try {
      final result = await WasmDatabase.open(
        databaseName: 'db',
        sqlite3Uri: Uri.parse('/sqlite3.wasm'),
        driftWorkerUri: Uri.parse('/drift_worker.dart.js'),
      );
      return result.resolvedExecutor; // result itu sendiri adalah DatabaseConnection
    } catch (e) {
      // Tangani kegagalan pemuatan WebAssembly di sini
      throw UnsupportedError('Failed to load WebAssembly components: $e');
    }
  }));
}