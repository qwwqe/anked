import 'package:anked/model/model.dart';
import 'package:flutter/material.dart';

class NoteContext {
  AnkiDeck deck;
  AnkiNoteModel _model;

  List<AnkiDeck> _decks;
  List<AnkiNoteModel> _models;

  List<TextEditingController> _controllers;
  List<VoidCallback> listeners;

  Note note;

  void renderNote() {
    if (note == null) {
      note = Note();
    }
    note.deckId = deck == null ? null : deck.id;
    note.modelId = _model == null ? null : _model.id;
    note.note = Map<String, dynamic>();
    note.note['fields'] = [];
    for(int i = 0; i < _model.fields.length; i++) {
      note.note['fields'].add({
        "name": _model.fields[i],
        "value": _controllers[i].text,
      });
    }
  }

  List<AnkiDeck> get decks => _decks;
  set decks(List<AnkiDeck> ds) {
    _decks = ds;
    if (deck == null && _decks.length != 0) {
      deck = _decks[0];
    }
  }

  List<AnkiNoteModel> get models => _models;
  set models(List<AnkiNoteModel> ms) {
    if (_controllers == null) {
      _controllers = List<TextEditingController>();
    }

    if (listeners == null) {
      listeners = List<VoidCallback>();
    }

    int max = 0;
    for (int i = 0; i < ms.length; i++) {
      if (ms[i].fields.length > max) {
        max = ms[i].fields.length;
      }
    }

    while (max > _controllers.length) {
      _controllers.add(TextEditingController());
      listeners.add(() {});
    }

    _models = ms;

    if (_model == null && _models.length > 0) {
      _model = _models[0];
    }
  }

  AnkiNoteModel get model => _model;
  set model(AnkiNoteModel m) {
    if (m != _model) {
      _detachListeners();
      //_clearControllers();
      _model = m;
    }
  }

  List<TextEditingController> get controllers => _controllers;

  void disposeControllers() {
    if (controllers != null) {
      controllers.forEach((c) => c.dispose());
    }
  }

  void _detachListeners() {
    for(int i = 0; i < _model.fields.length && i < _controllers.length && i < listeners.length; i++) {
      _controllers[i].removeListener(listeners[i]);
    }
  }

  void _clearControllers() {
    for(int i = 0; i < _model.fields.length; i++) {
      _controllers[i].clear();
    }
  }
}