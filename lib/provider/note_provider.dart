import 'package:sqflite/sqflite.dart';
import 'dart:core';
import 'dart:convert';

class NoteProvider {
  Database _database;

  Future<Database> getDatabase() async {
    if (_database == null) {
      var dbBasePath = await getDatabasesPath();
      var dbPath = dbBasePath + "/" + "notes.db";
      print(dbPath);
      _database = await openDatabase(dbPath, version: 1,
          onCreate: (Database db, int version) async {
            await db.execute(
                'CREATE TABLE notes (id INTEGER PRIMARY KEY, note TEXT);'
            );
          }
      );

      //await testPopulate(); // TODO: remove promptly
    }

    return _database;
  }

  Future<Map<String, dynamic>> getNote(int id) async {
    var db = await getDatabase();
    List<Map<String, dynamic>> rows = await db.query(
        'notes',
        columns: ['id', 'note'],
        where: 'id = ?',
        whereArgs: [id],
    );

    if (rows.length > 0) {
      return {
        "id": rows[0]['id'],
        "note": jsonDecode(rows[0]['note']),
      };
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDatabase();
    var rows = await db.rawQuery(
      'SELECT * FROM notes'
    );

    List<Map<String, dynamic>> notes = [];
    for(int i = 0; i < rows.length; i++) {
      var m = {
        "id": rows[i]['id'],
        "note": jsonDecode(rows[i]['note']),
      };
      notes.add(m);
    }

    return notes;
  }

  Future<void> testPopulate() async {
    var db = await getDatabase();
    var notes = [
      jsonEncode(<String, dynamic> {"fields":[{"name":"Chinese","value":"瑞霞"}]}),
      jsonEncode(<String, dynamic> {"fields":[{"name":"Chinese","value":"應運而生"}]}),
      jsonEncode(<String, dynamic> {"fields":[{"name":"Chinese","value":"宮闕"}]}),
    ];
    for (int i = 0; i < notes.length; i++) {
      db.insert("notes", <String, dynamic>{'note':notes[i]});
    }
  }
}