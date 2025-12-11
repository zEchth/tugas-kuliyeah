class TaskAttachment {
  final int id;
  final String taskId;
  final String ownerId;
  final String path;
  final String? url;
  final int size;
  final String mime;
  final DateTime createdAt;

  TaskAttachment({
    required this.id,
    required this.taskId,
    required this.ownerId,
    required this.path,
    required this.url,
    required this.size,
    required this.mime,
    required this.createdAt,
  });

  factory TaskAttachment.fromMap(Map<String, dynamic> map) {
    return TaskAttachment(
      id: map['id'] as int,
      taskId: map['task_id'] as String,
      ownerId: map['owner_id'] as String,
      path: map['path'] as String,
      url: map['url'] as String?,
      size: map['size'] as int,
      mime: map['mime'] as String,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'owner_id': ownerId,
      'path': path,
      'url': url,
      'size': size,
      'mime': mime,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
