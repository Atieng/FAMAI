import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageAuthor {
  user,
  model,
}

class ChatMessage {
  final String message;
  final MessageAuthor author;
  final Timestamp timestamp;

  ChatMessage({
    required this.message,
    required this.author,
    required this.timestamp,
  });
}
