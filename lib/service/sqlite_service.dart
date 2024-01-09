import 'package:flutter/material.dart';
import 'package:flutter_sqlite/model/note_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteService {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();

    return openDatabase(
      join(path, 'database.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE Notes(id INTEGER PRIMARY KEY AUTOINCREMENT,description TEXT NOT NULL)",
        );
      },
      version: 1,
    );
  }

  Future<int> createItem(Note note) async {
    final Database db = await initializeDB();
    final id = await db.insert('Notes', note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<List<Note>> getItems() async {
    final db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('Notes');
    return queryResult.map((e) => Note.fromMap(e)).toList();
  }

  Future<int> update(Note note) async {
    final db = await initializeDB();
    return db
        .update('Notes', note.toMap(), where: "id = ?", whereArgs: [note.id]);
  }

  Future<void> deleteItem(String id) async {
    final db = await initializeDB();
    try {
      await db.delete("Notes", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
