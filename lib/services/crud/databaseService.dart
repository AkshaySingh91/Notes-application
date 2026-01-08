import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

/*
instead opening db in different service & each table in different 
service we should create single database instance & create important
required table in its service, so that each service will not have to 
handle database related task 
*/
final dbName = 'notes_database.db';

final createUserTableQuery = """
CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
""";
final createNoteTableQuery = """
CREATE TABLE IF NOT EXISTS "notes" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"title"	TEXT NOT NULL,
	"body"	TEXT NOT NULL,
  "text_type" TEXT NOT NULL,
  "created_at" TEXT NOT NULL,
  "updated_at" TEXT,
  "is_synced_with_cloud" INTEGER DEFAULT 0,
  "is_done" INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id") ON DELETE CASCADE
);
""";
final createNoteTagQuery = """
CREATE TABLE IF NOT EXISTS note_tags (
  note_id INTEGER,
  tag_id INTEGER,
  FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
  FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);
""";
final createTagTableQuery = """  
CREATE TABLE IF NOT EXISTS tags (
  tag_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  material_tag_name TEXT,
  custom_tag_name TEXT,
  priority INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (user_id)
    REFERENCES user(id)
    ON DELETE CASCADE
);
""";

class DatabaseService {
  static final DatabaseService _sharedInstance = DatabaseService._internal();

  DatabaseService._internal();

  factory DatabaseService() => _sharedInstance;

  Database? _db;

  Future<Database> get database async {
    if (_db == null) {
      await _open();
    }
    return _db!;
  }

  Future<void> _open() async {
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      _db = await openDatabase(dbPath);
      // enable FK support
      await _db?.execute('PRAGMA foreign_keys = ON;');

      await _db?.execute(createUserTableQuery);
      await _db?.execute(createNoteTableQuery);
      await _db?.execute(createTagTableQuery);
      await _db?.execute(createNoteTagQuery);
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}
