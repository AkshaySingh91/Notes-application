import 'dart:async';
import 'package:my_learning_app/services/appSession/currentUserSession.dart';
import 'package:my_learning_app/services/crud/crudExceptions.dart';
import 'package:my_learning_app/services/crud/databaseService.dart';
import 'package:my_learning_app/services/crud/noteService.dart';

final tagTable = "tags";

final tagIdCol = "tag_id";
final materialTagNameCol = "material_tag_name";
final customTagNameCol = "custom_tag_name";
final priorityCol = "priority";
final userIdCol = "user_id";

class TagService {
  // singleton
  TagService._shared();
  static final _sharedInstance = TagService._shared();
  factory TagService() => _sharedInstance;

  List<NoteTag> _noteTag = [];

  late final StreamController<List<NoteTag>> _noteTagStreamController =
      StreamController<List<NoteTag>>.broadcast(
        onListen: () {
          _noteTagStreamController.add(_noteTag);
        },
      );

  Stream<List<NoteTag>> get stream => _noteTagStreamController.stream;

  Future<void> loadNoteTagsForUser() async {
    final allTags = await getAllNoteTags();
    _noteTag = allTags;
    _noteTagStreamController.sink.add(_noteTag);
  }

  Future<void> feedNoteTagData() async {
    final db = await DatabaseService().database;

    final DatabaseUser currentUser = UserSession.currentDbUser;
    final userId = currentUser.id;
    // Check if user already has tags
    final existing = await db.query(
      'tags',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (existing.isNotEmpty) return;

    final initialTags = [
      {'material': 'priority_high', 'custom': 'Important', 'priority': 1},
      {'material': 'check_circle_outline', 'custom': 'Todo', 'priority': 2},
      {'material': 'work_outline', 'custom': 'Work', 'priority': 3},
      {'material': 'school', 'custom': 'Study', 'priority': 4},
      {'material': 'lightbulb_outline', 'custom': 'Ideas', 'priority': 5},
      {'material': 'event', 'custom': 'Events', 'priority': 6},
      {'material': 'schedule', 'custom': 'Deadlines', 'priority': 7},
      {'material': 'home_outlined', 'custom': 'Home', 'priority': 8},
      {
        'material': 'shopping_cart_outlined',
        'custom': 'Shopping',
        'priority': 9,
      },
      {
        'material': 'health_and_safety_outlined',
        'custom': 'Health',
        'priority': 10,
      },
    ];

    final batch = db.batch();

    for (final tag in initialTags) {
      batch.insert('tags', {
        'user_id': userId,
        'material_tag_name': tag['material'],
        'custom_tag_name': tag['custom'],
        'priority': tag['priority'],
      });
    }

    await batch.commit(noResult: true);
  }

  Future<List<NoteTag>> getAllNoteTags() async {
    final db = await DatabaseService().database;
    final userId = await UserSession.currentDbUser.id;
    final result = await db.query(
      tagTable,
      where: "user_id = ?",
      whereArgs: [userId],
    );

    final noteTags = result.map((record) => NoteTag.fromRow(record)).toList();
    return noteTags;
  }

  Future<NoteTag> getNoteTag({required int tagId}) async {
    final db = await DatabaseService().database;
    final userId = await UserSession.currentDbUser.id;

    final tag = await db.query(
      tagTable,
      where: "user_id = ? AND tag_id = ?",
      whereArgs: [userId, tagId],
    );
    if (tag.isEmpty) {
      throw NoteTagNotFoundException();
    }
    return NoteTag.fromRow(tag.first);
  }

  Future<NoteTag> createNoteTag({
    required String materialIconName,
    required int priority,
    required String customIconName,
  }) async {
    final db = await DatabaseService().database;
    final userId = await UserSession.currentDbUser.id;

    final tagId = await db.insert(tagTable, {
      userIdCol: userId,
      materialTagNameCol: materialIconName,
      customTagNameCol: customIconName,
      priorityCol: priority,
    });
    if (tagId == 0) {
      throw NoteTagCreationException();
    }
    final newNoteTag = NoteTag(
      userId: userId,
      tagId: tagId,
      materialIconName: materialIconName,
      customTagName: customIconName,
      priority: priority,
    );
    // update cache
    _noteTag.add(newNoteTag);
    // add note in stream
    _noteTagStreamController.sink.add(_noteTag);
    return newNoteTag;
  }

  Future<void> deleteNoteTag({required int tagId}) async {
    final db = await DatabaseService().database;
    final userId = await UserSession.currentDbUser.id;

    final count = await db.delete(
      tagTable,
      where: "user_id = ? AND tag_id = ?",
      whereArgs: [userId, tagId],
    );
    if (count == 0) {
      throw NoteTagNotFoundException();
    }
    // delete note from stream
    _noteTag.removeWhere((note) => note.tagId == tagId);
    _noteTagStreamController.sink.add(_noteTag);
  }

  Future<void> updateNoteTag({
    required int tagId,
    required String materialIconName,
    required int priority,
    required String customIconName,
  }) async {
    await getNoteTag(tagId: tagId);

    final db = await DatabaseService().database;
    final userId = await UserSession.currentDbUser.id;

    final updateCount = await db.update(
      tagTable,
      {
        materialTagNameCol: materialIconName,
        priorityCol: priority,
        customTagNameCol: customIconName,
      },
      where: "user_id = ? AND tag_id = ?",
      whereArgs: [userId, tagId],
    );
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    }
    final updatedNoteTag = await getNoteTag(tagId: tagId);

    // update note in-place
    final index = _noteTag.indexWhere((tag) => tag.tagId == tagId);
    if (index != -1) {
      _noteTag[index] = updatedNoteTag;
    } else {
      _noteTag.add(updatedNoteTag);
    }
    // add updated notes in stream
    _noteTagStreamController.sink.add(_noteTag);
  }
}

// create a class for noteTag
class NoteTag {
  final int userId;
  final int tagId;
  final String materialIconName;
  final String customTagName;
  final int priority;

  const NoteTag({
    required this.userId,
    required this.tagId,
    required this.materialIconName,
    required this.customTagName,
    required this.priority,
  });
  NoteTag.fromRow(Map<String, Object?> record)
    : userId = record[userIdCol] as int,
      tagId = record[tagIdCol] as int,
      materialIconName = record[materialTagNameCol] as String,
      customTagName = record[customTagNameCol] as String,
      priority = record[priorityCol] as int;

  @override
  bool operator ==(covariant NoteTag other) {
    return other.tagId == tagId;
  }

  @override
  int get hashCode => tagId.hashCode;
}
