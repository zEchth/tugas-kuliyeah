class ShareTugas {
  final String id;
  final String taskId;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;
  final String status; // enum string: "pending", "accepted" dll

  ShareTugas({
    required this.id,
    required this.taskId,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    required this.status,
  });

  // -------- FROM SUPABASE --------
  factory ShareTugas.fromMap(Map<String, dynamic> map) {
    return ShareTugas(
      id: map['id'],
      taskId: map['task_id'],
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      createdAt: DateTime.parse(map['created_at']),
      status: map['status'],
    );
  }

  // -------- TO SUPABASE --------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }
}
