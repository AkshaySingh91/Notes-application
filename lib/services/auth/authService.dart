import 'package:my_learning_app/services/auth/authProvider.dart';
import 'package:my_learning_app/services/auth/firebaseAuthProvider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() {
    return AuthService(FirebaseAuthProvider());
  }
  @override
  Future<void> register(String email, String password) =>
      provider.register(email, password);
  @override
  Future<void> login(String email, String password) =>
      provider.login(email, password);

  @override
  Future<void> logout() => provider.logout();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
}
