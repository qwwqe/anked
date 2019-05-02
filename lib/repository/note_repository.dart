import 'package:anked/provider/provider.dart';

class NoteRepository {
  NoteProvider noteProvider;

  NoteRepository() {
    noteProvider = NoteProvider();
  }

  Future<List<Map<String, dynamic>>> getNoteList() async {
    return await noteProvider.getAllNotes();
  }

  Future<void> testPopulate() async {
    await noteProvider.testPopulate();
  }
}