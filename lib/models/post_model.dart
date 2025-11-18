import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorImageUrl;
  final String text;
  final String? imageUrl;
  final Timestamp timestamp;
  final List<String> likes;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorImageUrl,
    required this.text,
    this.imageUrl,
    required this.timestamp,
    this.likes = const [],
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      authorImageUrl: data['authorImageUrl'],
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: List<String>.from(data['likes'] ?? []),
    );
  }
}
