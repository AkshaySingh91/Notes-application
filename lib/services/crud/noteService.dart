import 'package:my_learning_app/services/crud/crudExceptions.dart';
import 'package:sqflite/sqflite.dart';
import "package:path/path.dart" show join;
import 'package:path_provider/path_provider.dart';

final dbName = 'notes_database.db';
final idColumn = 'id';
final emailColumn = 'email';
final userIdColumns = 'user_id';
final textColumn = 'text';
final isSyncedWithCloudColumn = 'is_synced_with_cloud';
final noteTable = 'notes';
final userTable = 'user';
final createUserTableQuery = """
CREATE TABLE IF NOT EXIST "user" (
	"id"	INTEGER,
	"email"	INTEGER NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
""";
final createNoteTableQuery = """
CREATE TABLE IF NOT EXIST "notes" (
	"id"	INTEGER,
	"user_id"	INTEGER,
	"text"	TEXT NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
""";

class NoteService {
  Database? _db;

  Future<DatabaseNote> updateNote({
    required int id,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();

    await getNote(id: id);

    final updateCount = await db.update(
      noteTable,
      {textColumn: text},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    }
    return await getNote(id: id);
  }

  Future<Iterable<DatabaseNote>> getAllNote() async {
    final db = _getDatabaseOrThrow();

    final notes = await db.query(noteTable);
    if (notes.isEmpty) {
      throw CouldNotFoundNote();
    }
    final result = notes.map((note) => DatabaseNote.fromRow(note));
    return result;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    final note = await db.query(
      noteTable,
      where: 'id: ?',
      whereArgs: [id],
      limit: 1,
    );
    if (note.isEmpty) {
      throw CouldNotFoundNote();
    }
    return DatabaseNote.fromRow(note.first);
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  Future<void> deleteNote({required id}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = getUser(email: owner.email);

    // check if requested user exist
    if (dbUser != owner) {
      throw UserNotFoundException();
    }

    final noteId = await db.insert(noteTable, {
      userIdColumns: owner.id,
      textColumn: '',
      isSyncedWithCloudColumn: 0,
    });

    if (noteId == 0) {
      throw NoteCreationException();
    }
    return DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: '',
      isSyncedWithCloud: false,
    );
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final result = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (result.isEmpty) {
      throw UserNotFoundException();
    }
    return DatabaseUser.fromRow(result.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    // check if user already exist
    final result = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );

    if (result.isNotEmpty) {
      throw UserAlreadyExistException();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    int deleteCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deleteCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    if (_db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await _db!.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create user table
      await db.execute(createNoteTableQuery);

      // create note table
      await db.execute(createNoteTableQuery);
    } on MissingPlatformDirectoryException {
    } catch (e) {}
  }
}

// Database rows should almost always be mapped to model classes.
/* 
when we query we got tuples from table in from of eg
{ename: Allen, sal: 1200, dept: 10} this is in from of Map<String, Object?> for single tuple for multiple tuple List<Map<String, Object?>>, Object? because if we access col which not present eg; age than it give {age: null} also key = String & value = object,as it cover everything like string, number, array, etc
Now, we can return Map<String, Object?> directly but it is not good practice we should create a modal for tuple like DatabaseUser & DatabaseNote this helps for error handling , strict type of attribute,data validation, easier to refactor
eg; suppose if DatabaseUser not crated & mujhe agar user ka info chiye jo locally store hai so than i called getUser now this function will return objec eg {ename, email, id, photoUrl} obj me kitne field hai vo pta nahi chalega thats why we have created DatabaseUser so that usme wrap hokar aayega aur vo data validation like id should be int, email should be string , etc check krlega plus hame auto-complete dekh ne ko milega jise pta chalega user obj ke pass kitne attr hai
*/

class DatabaseUser {
  final id;
  final email;

  const DatabaseUser({required int id, required String email})
    : id = id,
      email = email;

  DatabaseUser.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      email = map[emailColumn] as String;

  @override
  String toString() {
    return 'current user id= $id, email=$email';
  }

  @override
  bool operator ==(covariant DatabaseUser other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final id;
  final text;
  final userId;
  final isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });
  DatabaseNote.fromRow(Map<String, Object?> map)
    : id = map[idColumn],
      userId = map[userIdColumns],
      text = map[textColumn],
      isSyncedWithCloud = map[isSyncedWithCloudColumn];

  @override
  String toString() {
    return 'id= $id, userId=$userId isSyncedWithCloud=$isSyncedWithCloud text=$text';
  }

  @override
  bool operator ==(covariant DatabaseNote other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
