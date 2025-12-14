abstract class AuthProvider {
  Future<void> login(String email, String password);

  Future<void> register(String email, String password);
  Future<void> logout();
  Future<void> sendEmailVerification();
}
