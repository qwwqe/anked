import 'dart:core';
import 'package:anked/model/model.dart';
import 'package:flutter/services.dart';

class AnkiProvider {
  MethodChannel _platform;

  void setMethodChannel(MethodChannel c) {
    _platform = c;
  }

  Future<List<AnkiDeck>> getDecks() async {
    var decks = List<AnkiDeck>();
    try {
      Map<int, String> pDecks = await _platform.invokeMapMethod<int, String>('getDecks');
      pDecks.forEach((id, name) {
        decks.add(AnkiDeck(id: id.toString(), name: name));
      });
      print(pDecks);
    } on PlatformException catch (e) {
      print(e.message);
    }

    return decks;
  }

  Future<List<AnkiNoteModel>> getNoteModels() async {
    var models = List<AnkiNoteModel>();
    try {
      List<Map<dynamic, dynamic>> pModels = await _platform.invokeListMethod<Map<dynamic, dynamic>>('getModels');
      pModels.forEach((m) {
        var noteModel = AnkiNoteModel(
          name: m['name'],
          id: m['id'],
        );
        noteModel.loadFieldsFromString(m['fieldString']);
        models.add(noteModel);
      });
      print(pModels);
    } on PlatformException catch (e) {
      print(e.message);
    }

    return models;
  }

  Future<int> addNote(AnkiNote note) async {
    return await _platform.invokeMethod('saveNote', {
      "modelId": note.modelId,
      "deckId": note.deckId,
      "fieldString": note.fieldString,
    });
  }
}