class AnkiNote {
  String id;
  String name;
  String fieldString;
  String modelId;
  String deckId;
  List<String> fields;

  AnkiNote({this.id, this.name, this.deckId, this.modelId, this.fieldString});

  void loadFieldStringFromList(List<String> fields) {
    fieldString = fields.join("\u{1f}");
  }

}