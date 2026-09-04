import 'dart:io';

class Chat {
  String? sender_id;
  String? receiver_id;
  String? text;
  String? message_type;
  String? file_url;
  int? is_read;
  DateTime? created_at;
  File? file;
  bool? otherFiles = false;
  String? orignalFileName;

  Chat({
    this.sender_id,
    this.receiver_id,
    this.text,
    this.message_type,
    this.file_url,
    this.is_read,
    this.created_at,
    this.file,
    this.otherFiles,
    this.orignalFileName,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender_id': sender_id,
      'receiver_id': receiver_id,
      'text': text,
      'message_type': message_type,
      'file_url': file_url,
      'is_read': is_read,
      'created_at': created_at!.toIso8601String(),
      'otherFiles': otherFiles,
      'orignalFileName': orignalFileName,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      sender_id: map['sender_id'],
      receiver_id: map['receiver_id'],
      text: map['text'],
      message_type: map['message_type'],
      file_url: map['file_url'],
      is_read: map['is_read'],
      created_at: DateTime.parse(map['created_at']),
      otherFiles: map['otherFiles'],
      orignalFileName: map['orignalFileName'],
    );
  }
}
