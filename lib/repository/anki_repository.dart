import 'package:anked/provider/provider.dart';
import 'package:anked/model/model.dart';
import 'package:flutter/services.dart';

class AnkiRepository {
  AnkiProvider ankiProvider;
  AnkiInfo ankiInfo;

  AnkiRepository() {
    ankiProvider = AnkiProvider();
  }

  void setMethodChannel(MethodChannel c) {
    ankiProvider.setMethodChannel(c);
  }

  Future<AnkiInfo> getAnkiInfo({forceRefresh: false}) async {
    if (ankiInfo == null || forceRefresh) {
      var _ankiInfo = AnkiInfo();
      _ankiInfo.decks = await ankiProvider.getDecks();
      _ankiInfo.noteModels = await ankiProvider.getNoteModels();

      ankiInfo = _ankiInfo;
    }

    return ankiInfo;
  }

  Future<int> addNote(AnkiNote note) async {
    return await ankiProvider.addNote(note);
  }

  Future<bool> checkCardExistence(String modelId, String firstFieldName, String firstFieldValue) async {
    return await ankiProvider.checkCardExistence(modelId, firstFieldName, firstFieldValue);
  }
}