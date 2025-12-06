// // lib/features/tugas/add_edit_tugas_screen.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tugas_kuliyeah/core/models/tugas.dart' as core_model;
import 'package:tugas_kuliyeah/core/providers.dart';
import 'package:uuid/uuid.dart';

class AddEditTugasScreen extends ConsumerStatefulWidget {
  final String mataKuliahId;
  final core_model.Tugas? tugas;

  const AddEditTugasScreen({super.key, required this.mataKuliahId, this.tugas});

  @override
  ConsumerState<AddEditTugasScreen> createState() => _AddEditTugasScreenState();
}

class _AddEditTugasScreenState extends ConsumerState<AddEditTugasScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEditing;

  late TextEditingController _titleC;
  late TextEditingController _noteC;

  String? _selectedJenis;
  DateTime? _dueAt;

  List<String> _attachmentPathList = [];
  List<PlatformFile> _webFiles = [];

  final List<String> _jenisList = ["Tugas", "Kuis", "UTS", "UAS"];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.tugas != null;

    _titleC = TextEditingController(
      text: _isEditing ? widget.tugas!.title : '',
    );

    _noteC = TextEditingController(text: _isEditing ? widget.tugas!.note : '');

    _selectedJenis = _isEditing ? widget.tugas!.type : null;
    _dueAt = _isEditing ? widget.tugas!.dueAt : null;
    // _attachmentPath = _isEditing ? widget.tugas!.attachmentPath : null;
  }

  @override
  void dispose() {
    _titleC.dispose();
    _noteC.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueAt ?? DateTime.now()),
    );

    if (time == null) return;

    setState(() {
      _dueAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result == null) return;

    if (kIsWeb) {
      // Web pakai bytes
      setState(() {
        _webFiles = result.files; // semua file masuk
      });
    } else {
      // Android/iOS pakai path biasa
      setState(() {
        _attachmentPathList = result.paths.whereType<String>().toList();
      });
    }
    // _attachmentPathList = result.paths.whereType<String>().toList();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _selectedJenis == null ||
        _dueAt == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Harap lengkapi semua data")));
      return;
    }

    final user = ref.read(userProvider);

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User tidak ditemukan")));
      return;
    }

    final repo = ref.read(taskRepositoryProvider);

    final id = _isEditing ? widget.tugas!.id : const Uuid().v4();

    final tugas = core_model.Tugas(
      id: id,
      ownerId: user.id,
      title: _titleC.text,
      type: _selectedJenis!,
      note: _noteC.text.isNotEmpty ? _noteC.text : null,
      dueAt: _dueAt!,
      createdAt: _isEditing ? widget.tugas!.createdAt : DateTime.now(),
      mataKuliahId: widget.mataKuliahId,
      // attachmentPath: _attachmentPath,
    );

    try {
      if (_isEditing) {
        await repo.updateTugas(tugas);
      } else {
        await repo.insertTugas(tugas);
      }

      // upload attachment baru
      if (kIsWeb) {
        for (final file in _webFiles) {
          await repo.uploadAttachmentWeb(taskId: id, file: file);
        }
      } else {
        for (final path in _attachmentPathList) {
          await repo.uploadAttachment(taskId: id, filePath: path);
        }
      }

      ref.read(globalRefreshProvider.notifier).state++;

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Tugas disimpan")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(taskRepositoryProvider);

    final attachmentsAsync = _isEditing
        ? ref.watch(attachmentsByTaskProvider(widget.tugas!.id))
        : const AsyncValue.data([]);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? "Edit Tugas" : "Tambah Tugas")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleC,
                decoration: InputDecoration(labelText: "Judul Tugas"),
                validator: (v) => v!.isEmpty ? "Judul wajib diisi" : null,
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedJenis,
                hint: Text("Pilih Jenis"),
                items: _jenisList
                    .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedJenis = v),
                validator: (v) => v == null ? "Jenis wajib dipilih" : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _noteC,
                decoration: InputDecoration(labelText: "Deskripsi"),
              ),
              SizedBox(height: 16),

              ElevatedButton.icon(
                icon: Icon(Icons.calendar_today),
                label: Text(
                  _dueAt == null
                      ? "Pilih Tenggat Waktu"
                      : DateFormat("dd MMM yyyy, HH:mm").format(_dueAt!),
                ),
                onPressed: _pickDeadline,
              ),
              SizedBox(height: 16),

              Text("Lampiran:", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),

              // --- TAMPILKAN LAMPIRAN EXISTING (kalau mode edit) ---
              if (_isEditing)
                attachmentsAsync.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return Text(
                        "Tidak ada lampiran",
                        style: TextStyle(color: Colors.grey),
                      );
                    }

                    return Column(
                      children: list.map((att) {
                        final fileName = att.path.split('/').last;

                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.insert_drive_file),
                            title: Text(
                              fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await repo.deleteAttachment(att.id);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (_, __) => Text("Gagal memuat lampiran"),
                ),

              SizedBox(height: 8),

              // --- PILIH FILE BARU ---
              Card(
                child: ListTile(
                  leading: Icon(Icons.attach_file),
                  title: Text(
                    "Tambahkan lampiran tugas",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.folder_open),
                    onPressed: _pickFile,
                  ),
                ),
              ),

              // zech
              if (kIsWeb)
                Column(
                  children: _webFiles.map((file) {
                    return ListTile(
                      leading: Icon(Icons.upload_file),
                      title: Text(file.name),
                      trailing: IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _webFiles.remove(file);
                          });
                        },
                      ),
                    );
                  }).toList(),
                )
              else
                Column(
                  children: _attachmentPathList.map((path) {
                    return ListTile(
                      leading: Icon(Icons.upload_file),
                      title: Text(path.split('/').last),
                      trailing: IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _attachmentPathList.remove(path);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),

              // Column(
              //   children: _attachmentPathList.map((path) {
              //     return ListTile(
              //       leading: Icon(Icons.upload_file),
              //       title: Text(path.split('/').last),
              //       trailing: IconButton(
              //         icon: Icon(Icons.close, color: Colors.red),
              //         onPressed: () {
              //           setState(() {
              //             _attachmentPathList.remove(path);
              //           });
              //         },
              //       ),
              //     );
              //   }).toList(),
              // ),

              SizedBox(height: 30),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                ),
                child: Text("Simpan Tugas"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
