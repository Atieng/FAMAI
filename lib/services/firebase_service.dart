import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore, QuerySnapshot, SetOptions;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:famai/models/chat_message.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserDocument(User user, String name) async {
    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'email': user.email,
      'createdAt': DateTime.now().toString(),
    }, SetOptions(merge: true));
  }
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signUpWithEmailAndPassword(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await _createUserDocument(user.uid, name, email);
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Create or update the user document in Firestore
        final userDocRef = _firestore.collection('users').doc(user.uid);
        final userDoc = await userDocRef.get();

        if (!userDoc.exists) {
          // New user, create the document
          await userDocRef.set({
            'name': user.displayName,
            'email': user.email,
            'profile_picture': user.photoURL,
          });
        } else {
          // Existing user, update if necessary
          await userDocRef.set({
            'name': user.displayName,
            'email': user.email,
            'profile_picture': user.photoURL,
          }, SetOptions(merge: true));
        }
      }


      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _createUserDocument(String uid, String name, String email) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': DateTime.now().toString(),
    }, SetOptions(merge: true));
  }

  Future<void> saveChatMessage(ChatMessage message) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('chat_history')
        .add({
      'message': message.message,
      'author': message.author.toString(),
      'timestamp': message.timestamp,
    });
  }

  Stream<QuerySnapshot> getChatHistory() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('chat_history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
