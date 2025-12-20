import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_learning_app/services/crud/noteService.dart';

class MyAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isInitialized = false;
  bool _isCheckingVerification = false;

  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _user != null;
  User? get currentUser => _user;
  bool get isEmailVerified => _user?.emailVerified ?? false;
  bool get isCheckingVerification => _isCheckingVerification;

  MyAuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _auth.authStateChanges().listen((User? u) {
      _user = u;
      _isInitialized = true;
      notifyListeners();
    });
  }

  Future<void> updateUserFromFirebase() async {
    try {
      if (_auth.currentUser == null) {
        _user = null;
      } else {
        await _auth.currentUser!.reload();
        _user = _auth.currentUser;
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // optional: handle/log error
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> refreshVerificationStatus() async {
    if (_auth.currentUser == null) return;

    _isCheckingVerification = true;
    notifyListeners();

    await _auth.currentUser!.reload();
    _user = _auth.currentUser; // Refresh local reference

    if (isEmailVerified) {
      final noteService = NoteService();
      final databaseUser = await noteService.getOrCreateUser(
        email: currentUser!.email!,
      );
    }
  }
}
