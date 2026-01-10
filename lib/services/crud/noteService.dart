import 'dart:async';
import 'package:my_learning_app/services/appSession/currentUserSession.dart';
import 'package:my_learning_app/services/crud/crudExceptions.dart';
import 'package:my_learning_app/services/crud/databaseService.dart';
import 'package:my_learning_app/services/crud/tagService.dart';
import 'package:sqflite/sqflite.dart';

final userTableEmailColumn = 'email';

final noteTable = 'notes';
final noteTagTable = 'note_tags';

final idColumn = 'id';
final userIdColumn = 'user_id';
final titleColumn = 'title';
final bodyColumn = 'body';
final textTypeColumn = 'text_type';
final createdAtColumn = 'created_at';
final updatedAtColumn = 'updated_at';
final isDoneColumn = 'is_done';
final isSyncedWithCloudColumn = 'is_synced_with_cloud';

final tagIdColumn = 'tag_id';
final noteIdColumn = 'note_id';

final class NoteService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  // we have to create singleton to maintain data consistency across app
  static final _shared = NoteService._sharedInstance();

  // when ever we create instance it will return same object ie _shared
  factory NoteService() => _shared;

  // this is private constructor means when we call this in this class only we get Noteservice object which we will store in _shared which is static means common for all instance
  NoteService._sharedInstance() {
    _noteStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _noteStreamController.sink.add(_notes);
      },
    );
  }

  // a = NoteService()
  // 1. _shared = NoteService._sharedInstance(); it will run & _shared will store instance object
  // 2. factory const will return that object also this is store in memory & common for all , so if another variable created eg;
  // b = NoteService(); factory constructor will call & check if _shared is present in memory or not , yes! it present so it will return same object to b
  // now , a & b both contains same class instance

  late final StreamController<List<DatabaseNote>> _noteStreamController;

  // this will add updated notes each time when changes occur & add updated notes in stream
  Future<void> loadNotesForUser() async {
    final allNotes = await getAllNotes();
    _notes = allNotes;
    _noteStreamController.sink.add(_notes);
    print("total notes are : ${_notes.length}");
  }

  Stream<List<DatabaseNote>> get stream => _noteStreamController.stream;

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
      _db = await DatabaseService().database;
    } catch (_) {
      rethrow;
    }
  }

  Future<DatabaseNote> createNote({
    required String title,
    required String body,
    required List<NoteTag> noteTags,
  }) async {
    // get database instance
    final db = await DatabaseService().database;
    // get current database user, if it will null it throw UserNotFoundException
    final dbUser = UserSession.currentDbUser;

    final createdAt = DateTime.now().toString();
    // first note will insert
    final noteId = await db.insert(noteTable, {
      userIdColumn: dbUser.id,
      titleColumn: title,
      bodyColumn: body,
      textTypeColumn: 'text',
      createdAtColumn: createdAt,
      updatedAtColumn: createdAt,
      isSyncedWithCloudColumn: 0,
      isDoneColumn: 0,
    });

    if (noteId == 0) {
      throw NoteCreationException();
    }
    // after that all note tag will insert
    for (final tag in noteTags) {
      await db.insert(noteTagTable, {
        noteIdColumn: noteId,
        tagIdCol: tag.tagId,
      });
    }

    // add updated notes in stream
    final newNote = DatabaseNote(
      id: noteId,
      userId: dbUser.id,
      title: title,
      body: body,
      textType: 'text',
      createdAt: createdAt,
      updatedAt: null,
      isSyncedWithCloud: 0,
      isDone: 0,
    );

    _notes.add(newNote);
    _noteStreamController.sink.add(_notes);
    return newNote;
  }

  Future<List<NoteTag>> getAllTagsOfSpecificNote({required int noteId}) async {
    //1. first we get note id
    //2. check if note exist
    //3. after that we have to fetch all tagsid whose noteid given
    //4. for all those tagid we have to get all tags from tag table
    //5. wrap it in NoteTag class & send List<NoteTag>
    await getNote(id: noteId);
    final db = await DatabaseService().database;
    final tagMapList = await db.query(
      noteTagTable,
      where: '$noteIdColumn  = ?',
      whereArgs: [noteId],
    );
    //eg; [{note_id: 1, tag_id: 2}, {note_id: 1, tag_id: 3}]
    List<NoteTag> allTags = [];
    final tagService = TagService();
    for (final idMap in tagMapList) {
      final tagId = idMap[tagIdColumn].toString();
      final tag = await tagService.getNoteTag(tagId: int.tryParse(tagId) ?? 0);
      allTags.add(tag);
    }
    return allTags;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = await DatabaseService().database;
    final dbUser = UserSession.currentDbUser;

    final note = await db.query(
      noteTable,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, dbUser.id],
    );
    if (note.isEmpty) {
      throw CouldNotFoundNote();
    }
    return DatabaseNote.fromRow(note.first);
  }

  Future<List<DatabaseNote>> getAllNotes() async {
    final db = await DatabaseService().database;

    final notes = await db.query(noteTable);

    final result = notes.map((note) => DatabaseNote.fromRow(note)).toList();
    return result;
  }

  Future<DatabaseNote> updateNoteText({
    required int id,
    required String title,
    required String body,
    required List<NoteTag> noteTags,
  }) async {
    final db = await DatabaseService().database;
    final dbUser = UserSession.currentDbUser;
    // check if actually note exists, else throw
    await getNote(id: id);

    final updateCount = await db.update(
      noteTable,
      {titleColumn: title, bodyColumn: body},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, dbUser.id],
    );

    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    }
    //1. user may add or delete some tags
    //2. first get all old tags
    //3. delete those which are not present in noteTags param
    //4. add those which are present in noteTags param

    final oldTag = await getAllTagsOfSpecificNote(noteId: id);

    // tag that are present in old but absent in new are deleted
    final deletedTags = oldTag.where(
      (tag) => !noteTags.any((t) => tag.tagId == t.tagId),
    );

    for (final tag in deletedTags) {
      await db.delete(
        noteTagTable,
        where: '$tagIdCol = ? AND $noteIdColumn = ?',
        whereArgs: [tag.tagId, id],
      );
    }
    // tag that are present in new but not in old is new
    final newTags = noteTags.where(
      (tag) => !oldTag.any((t) => tag.tagId == t.tagId),
    );

    for (final tag in newTags) {
      await db.insert(noteTagTable, {noteIdColumn: id, tagIdColumn: tag.tagId});
    }
    final updatedNote = await getNote(id: id);

    // update note in-place
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = updatedNote;
    } else {
      _notes.add(updatedNote);
    }
    // add updated notes in stream
    _noteStreamController.sink.add(_notes);

    return updatedNote;
  }

  Future<DatabaseNote> updateNoteIsDone({
    required int id,
    required bool isDone,
  }) async {
    final db = await DatabaseService().database;
    final dbUser = UserSession.currentDbUser;

    // check if note exist, else throw
    await getNote(id: id);

    final updateCount = await db.update(
      noteTable,
      {isDoneColumn: isDone ? 0 : 1},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, dbUser.id],
    );
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    }
    // now note have update in-place so that order of list will not change
    final index = _notes.indexWhere((note) => note.id == id);
    final updatedNote = await getNote(id: id);
    if (index != -1) {
      _notes[index] = updatedNote;
    } else {
      _notes.add(updatedNote);
    }
    _noteStreamController.sink.add(_notes);
    return updatedNote;
  }

  Future<int> deleteAllNotes() async {
    final db = await DatabaseService().database;
    int count = await db.delete(noteTable);
    // add updated notes in
    _notes = [];
    _noteStreamController.sink.add(_notes);
    return count;
  }

  Future<void> deleteNote({required int id}) async {
    final db = await DatabaseService().database;
    final dbUser = UserSession.currentDbUser;

    final deleteCount = await db.delete(
      noteTable,
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, dbUser.id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    }
    // delete note from stream
    _notes.removeWhere((note) => note.id == id);
    _noteStreamController.sink.add(_notes);
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
      email = map[userTableEmailColumn] as String;

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
  final userId;
  final title;
  final body;
  final textType;
  final createdAt;
  final updatedAt;
  final isSyncedWithCloud;
  final isDone;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.textType,
    required this.createdAt,
    required this.updatedAt,
    required this.isSyncedWithCloud,
    required this.isDone,
  });
  DatabaseNote.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      title = map[titleColumn] as String,
      body = map[bodyColumn] as String,
      textType = map[textTypeColumn] as String,
      createdAt = map[createdAtColumn] as String,
      updatedAt = map[updatedAtColumn] as String,
      isDone = map[isDoneColumn] as int,
      isSyncedWithCloud = map[isSyncedWithCloudColumn] as int;

  @override
  String toString() {
    return 'id= $id, userId=$userId isSyncedWithCloud=$isSyncedWithCloud title=$title';
  }

  @override
  bool operator ==(covariant DatabaseNote other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
