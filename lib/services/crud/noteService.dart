import 'dart:async';
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
CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER,
	"email"	INTEGER NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
""";
final createNoteTableQuery = """
CREATE TABLE IF NOT EXISTS "notes" (
	"id"	INTEGER,
	"user_id"	INTEGER,
	"text"	TEXT NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
""";

class NoteService {
  Database? _db;
  DatabaseUser? _user;

  List<DatabaseNote> _notes = [];

  // we have to create singleton to maintain data consistency across app
  static final _shared = NoteService._sharedInstance();

  // when ever we create instance it will return same object ie _shared
  factory NoteService() => _shared;

  // this is private constructor means when we call this in this class only we get Noteservice object which we will store in _shared which is static means common for all instance
  NoteService._sharedInstance();

  // a = NoteService()
  // 1. _shared = NoteService._sharedInstance(); it will run & _shared will store instance object
  // 2. factory const will return that object also this is store in memory & common for all , so if another variable created eg;
  // b = NoteService(); factory constructor will call & check if _shared is present in memory or not , yes! it present so it will return same object to b
  // now , a & b both contains same class instance

  final _noteStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

  // this will add updated notes each time when changes occur & add updated notes in stream
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes;
    _noteStreamController.sink.add(_notes);
  }

  Stream<List<DatabaseNote>> get stream => _noteStreamController.stream;

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);

      // enable FK support
      await db.execute('PRAGMA foreign_keys = ON;');
      _db = db;
      // create user table
      await db.execute(createUserTableQuery);

      // create note table
      await db.execute(createNoteTableQuery);

      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      //
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkAllTable() async {
    final docsPath = await getApplicationDocumentsDirectory();
    final dbPath = join(docsPath.path, dbName);
    final db = await openDatabase(dbPath);
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
    );
    print('tables: $tables');
  }

  Future<void> close() async {
    if (_db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await _db!.close();
      _db = null;
    }
  }

  Future<void> _ensureDBIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // Do nothing
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDBIsOpen();

    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);

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
    // add updated notes in stream

    final newNote = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: '',
      isSyncedWithCloud: false,
    );
    _notes.add(newNote);
    _noteStreamController.sink.add(_notes);
    return newNote;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDBIsOpen();

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

  // Stream<List<DatabaseNote>> get allNotes =>
  //     _noteStreamController.stream.((note) {
  //       final currentUser = _user;
  //       if (currentUser != null) {
  //         return note.userId == currentUser.id;
  //       } else {
  //         throw UserShouldBeSetBeforeReadingAllNotes();
  //       }
  //     });

  Future<List<DatabaseNote>> getAllNotes() async {
    await _ensureDBIsOpen();

    final db = _getDatabaseOrThrow();

    final notes = await db.query(noteTable);
    final result = notes.map((note) => DatabaseNote.fromRow(note)).toList();
    return result;
  }

  Future<DatabaseNote> updateNote({
    required int id,
    required String text,
  }) async {
    await _ensureDBIsOpen();

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
    final updatedNote = await getNote(id: id);

    // add updated notes in stream
    _notes.removeWhere((note) => note.id == id);
    _notes.add(updatedNote);
    _noteStreamController.sink.add(_notes);

    return updatedNote;
  }

  Future<int> deleteAllNotes() async {
    await _ensureDBIsOpen();

    final db = _getDatabaseOrThrow();
    int count = await db.delete(noteTable);
    // add updated notes in
    _notes = [];
    _noteStreamController.sink.add(_notes);
    return count;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDBIsOpen();

    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    }
    // add updated notes in stream
    _notes.removeWhere((note) => note.id == id);
    _noteStreamController.sink.add(_notes);
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      _user = user;

      return user;
    } on UserNotFoundException {
      final user = await createUser(email: email);
      _user = user;

      return user;
    } catch (_) {
      rethrow;
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDBIsOpen();

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
    await _ensureDBIsOpen();
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
