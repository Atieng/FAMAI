import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:famai/models/post_model.dart';
import 'package:famai/models/comment_model.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Post>> getPosts() {
    return _firestore
        .collection('community_posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  Future<void> addPost(String text, {String? imageUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final authorName = userDoc.data()?['name'] ?? 'Anonymous';

    await _firestore.collection('community_posts').add({
      'authorId': user.uid,
      'authorName': authorName,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
      'likes': [],
    });
  }

  Future<void> toggleLike(String postId, bool isLiked) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final postRef = _firestore.collection('community_posts').doc(postId);
    if (isLiked) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([user.uid])
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([user.uid])
      });
    }
  }

  Future<void> addComment(String postId, String text) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final authorName = userDoc.data()?['name'] ?? 'Anonymous';

    await _firestore
        .collection('community_posts')
        .doc(postId)
        .collection('comments')
        .add({
      'authorId': user.uid,
      'authorName': authorName,
      'text': text,
      'timestamp': Timestamp.now(),
    });
  }

  Stream<List<Comment>> getComments(String postId) {
    return _firestore
        .collection('community_posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final commentRef = _firestore
        .collection('community_posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);
    
    final comment = await commentRef.get();
    if (comment.exists && comment['authorId'] == user.uid) {
      await commentRef.delete();
    }
  }

  Future<int> getCommentCount(String postId) async {
    final snapshot = await _firestore
        .collection('community_posts')
        .doc(postId)
        .collection('comments')
        .get();
    return snapshot.docs.length;
  }
}
