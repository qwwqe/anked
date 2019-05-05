class AnkiInfo {
  List<AnkiDeck> decks;
  List<AnkiNoteModel> noteModels;
}

class AnkiDeck {
  String id;
  String name;

  AnkiDeck({this.id, this.name});
}

class AnkiNoteModel {
  String id;
  String name;
  List<String> fields;

  AnkiNoteModel({this.id, this.name, this.fields});

  void loadFieldsFromString(String s) {
    fields = s.split('\u{1f}');
  }
}