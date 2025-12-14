import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_learning_app/services/auth/authExceptions.dart';
import 'package:my_learning_app/services/auth/authProvider.dart'
    as MyAuthProvider;

class FirebaseAuthProvider implements MyAuthProvider.AuthProvider {
  @override
  Future<void> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-credential") {
        throw WrongPasswordException();
      } else if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> register(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        throw WeakPasswordException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUserException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } catch (_) {
      throw GenericAuthException();
    }
  }
}
