import 'package:sqflite/sqflite.dart';
import 'dart:core';
import 'dart:convert';
import 'package:anked/model/model.dart';

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
                'CREATE TABLE notes (id INTEGER PRIMARY KEY, modelId TEXT, deckId TEXT, note TEXT);'
            );
          }
      );
    }

    return _database;
  }

  Future<Note> getNote(int id) async {
    var db = await getDatabase();
    List<Map<String, dynamic>> rows = await db.query(
        'notes',
        columns: ['id', 'modelId', 'deckId', 'note'],
        where: 'id = ?',
        whereArgs: [id],
    );

    if (rows.length > 0) {
      return Note(
        id: rows[0]['id'],
        modelId: rows[0]['modelId'],
        deckId: rows[0]['deckId'],
        note: jsonDecode(rows[0]['note']),
      );
    }

    return null;
  }

  Future<List<Note>> getAllNotes() async {
    var db = await getDatabase();
    var rows = await db.rawQuery(
      'SELECT * FROM notes'
    );

    print("FFFF");
    List<Note> notes = [];
    for(int i = 0; i < rows.length; i++) {
      var m = Note(
        id: rows[i]['id'],
        modelId: rows[i]['modelId'],
        deckId: rows[i]['deckId'],
        note: jsonDecode(rows[i]['note']),
      );
      notes.add(m);
    }
    print("GGGG");

    return notes;
  }

  Future<Note> saveNote(Note note) async {
    var db = await getDatabase();
    int count = 1;

    print(note.note);

    if (note.id != null) {
      count = await db.update(
          "notes",
          {
            "deckId": note.deckId,
            "modelId": note.modelId,
            "note": jsonEncode(note.note),
          },
          where: "id = ?",
          whereArgs: [note.id],
      );
    } else {
      int newId = await db.insert(
        "notes",
        {
          "deckId": note.deckId,
          "modelId": note.modelId,
          "note": jsonEncode(note.note),
        },
      );
      note.id = newId;
    }

    if (count < 1) {
      throw("Error updating note.");
    }

    return note;
  }

  Future<void> deleteNote(Note note) async {
    var db = await getDatabase();
    print("DELETING NOTE WITH ID: " + note.id.toString());
    await db.delete("notes", where: "id = ?", whereArgs: [note.id]);
  }

  Future<void> testPopulate() async {
    var db = await getDatabase();
    var notes = [
      jsonEncode(<String, dynamic> {"fields":[{"name":"Chinese","value":"瑞霞"}]}),
      jsonEncode(<String, dynamic> {"fields":[{"name":"Chinese","value":"應運而生"}]}),
      jsonEncode(<String, dynamic> {"fields":[{"name":"Chinese","value":"宮闕"}]}),
    ];
    for (int i = 0; i < notes.length; i++) {
      await db.insert("notes", <String, dynamic>{"deckId":"234", "modelId":"42","note":notes[i]});
    }
  }
}