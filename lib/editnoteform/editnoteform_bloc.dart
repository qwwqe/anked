import 'package:bloc/bloc.dart';
import 'package:anked/editnoteform/editnoteform.dart';
import 'package:anked/repository/repository.dart';
import 'package:anked/model/model.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

class EditNoteFormBloc extends Bloc<EditNoteFormEvent, EditNoteFormState> {
  final NoteContext noteContext;
  final NoteRepository noteRepository;

  bool preloaded = false;

  EditNoteFormBloc({@required this.noteContext, @required this.noteRepository}) :
      assert(noteContext != null),
      assert(noteRepository != null);

  @override
  EditNoteFormState get initialState => DeckChanged(deck: noteContext.deck);

  @override
  Stream<EditNoteFormState> mapEventToState(EditNoteFormEvent event) async* {
    if (event is ModifyDeck) {
      noteContext.deck = event.deck;
      yield DeckChanged(deck: event.deck);
    }

    if (event is ModifyField) {
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
    }
  }

  void _fieldUpdateCallback(int i) {
    print(noteContext.controllers[i].text);
  }
}