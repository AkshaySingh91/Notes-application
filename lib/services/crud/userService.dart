import 'package:my_learning_app/services/auth/authExceptions.dart';
import 'package:my_learning_app/services/crud/crudExceptions.dart';
import 'package:my_learning_app/services/crud/databaseService.dart';
import 'package:my_learning_app/services/crud/noteService.dart';
import 'package:sqflite/sqflite.dart';

final userTable = 'user';
final emailColumn = 'email';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  Future<Database> get _db async => await DatabaseService().database;

  Future<DatabaseUser> getUser({required String email}) async {
    final db = await _db;

    final result = await db.query(
      userTable,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );

    if (result.isEmpty) {
      throw UserNotFoundException();
    }

    return DatabaseUser.fromRow(result.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = await _db;

    final existing = await db.query(
      userTable,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      throw UserAlreadyExistException();
    }

    final id = await db.insert(userTable, {emailColumn: email.toLowerCase()});

    return DatabaseUser(id: id, email: email);
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      return await getUser(email: email);
    } on UserNotFoundException {
      return await createUser(email: email);
    }
  }

  Future<void> deleteUser({required String email}) async {
    final db = await _db;

    final count = await db.delete(
      userTable,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (count != 1) {
      throw CouldNotDeleteUserException();
    }
  }
}
