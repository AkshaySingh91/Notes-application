import 'package:my_learning_app/services/auth/authExceptions.dart';
import 'package:my_learning_app/services/crud/noteService.dart';
import 'package:my_learning_app/services/crud/userService.dart';

class UserSession {
  static DatabaseUser? _currentDbUser;

  static DatabaseUser get currentDbUser {
    if (_currentDbUser == null) {
      throw UserNotFoundException();
    }
    return _currentDbUser!;
  }

  static Future<void> initializeForUser(String email) async {
    _currentDbUser = await UserService().getOrCreateUser(email: email);
  }

  static void clear() {
    _currentDbUser = null;
  }
}
