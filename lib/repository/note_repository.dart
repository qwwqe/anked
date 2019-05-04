import 'package:anked/provider/provider.dart';
import 'package:anked/model/model.dart';

class NoteRepository {
  NoteProvider noteProvider;

  NoteRepository() {
    noteProvider = NoteProvider();
  }

  Future<List<Note>> getNoteList() async {
    return await noteProvider.getAllNotes();
  }

  Future<Note> saveNote(Note note) async {
    return await noteProvider.saveNote(note);
  }

  Future<void> deleteNote(Note note) async {
    await noteProvider.deleteNote(note);
  }

  Future<void> testPopulate() async {
    await noteProvider.testPopulate();
  }
}