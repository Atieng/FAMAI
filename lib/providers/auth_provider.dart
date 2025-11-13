import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  User? _user;
  AuthStatus _status = AuthStatus.uninitialized;

  AuthProvider() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  AuthStatus get status => _status;
  User? get user => _user;

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
    } else {
      _user = firebaseUser;
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      // TODO: Handle errors
      return null;
    }
  }

  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      // TODO: Handle errors
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // TODO: Implement Google Sign-In
  // TODO: Implement Delete Account
}
