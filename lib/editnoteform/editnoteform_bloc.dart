import 'package:bloc/bloc.dart';
import 'package:anked/editnoteform/editnoteform.dart';
import 'package:anked/repository/repository.dart';
import 'package:anked/model/model.dart';
import 'package:meta/meta.dart';
import 'package:anked/editnote/editnote.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class EditNoteFormBloc extends Bloc<EditNoteFormEvent, EditNoteFormState> {
  final NoteContext noteContext;
  final NoteRepository noteRepository;
  final EditNoteBloc editNoteBloc;

  Timer saveTimer;

  bool preloaded = false;

  EditNoteFormBloc({@required this.noteContext, @required this.noteRepository, @required this.editNoteBloc}) :
      assert(noteContext != null),
      assert(noteRepository != null),
      assert(editNoteBloc != null);

  @override
  EditNoteFormState get initialState => DeckChanged(deck: noteContext.deck);

  @override
  Stream<EditNoteFormState> mapEventToState(EditNoteFormEvent event) async* {
    if (event is ModifyDeck) {
      AnkiDeck deck;
      for (int i = 0; i < noteContext.decks.length; i++) {
        if(noteContext.decks[i].id == event.deckId) {
          deck = noteContext.decks[i];
          break;
        }
      }

      if (deck != null) {
        noteContext.deck = deck;
        yield DeckChanged(deck: deck);
        editNoteBloc.dispatch(SaveNote());
      }
    }

    if (event is ModifyField) {
      _fieldUpdate(event.fieldIndex);
      yield FieldChanged(fieldIndex: event.fieldIndex, fieldValue: event.fieldValue);
    }

    if (event is ModifyNoteModel) {
      noteContext.model = event.noteModel;
      for (int i = 0; i < noteContext.controllers.length; i++) {
        noteContext.listeners[i] = () {
          this.dispatch(ModifyField(
            fieldIndex: i,
            fieldValue: noteContext.controllers[i].text,
          ));
        };
        noteContext.controllers[i].addListener(noteContext.listeners[i]);

        if (!preloaded && noteContext.note != null && noteContext.note.modelId == noteContext.model.id) {
          preloaded = true;
          for(int i = 0; i < noteContext.model.fields.length && i < noteContext.note.note['fields'].length; i++) {
            noteContext.controllers[i].text = noteContext.note.note['fields'][i]['value'];
          }
        }
      }

      yield NoteModelChanged(noteModel: event.noteModel);
      editNoteBloc.dispatch(SaveNote());
    }
  }

  void _fieldUpdate(int i) {
    print(noteContext.controllers[i].text);
    if (saveTimer != null) {
      saveTimer.cancel();
    }
    saveTimer = Timer(Duration(seconds: 1), () {
      editNoteBloc.dispatch(SaveNote());
    });
  }
}