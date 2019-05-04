import 'dart:async';
import 'package:anked/editnote/editnote.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:anked/model/model.dart';
import 'package:anked/repository/repository.dart';

class EditNoteBloc extends Bloc<EditNoteEvent, EditNoteState> {
  final NoteRepository noteRepository;
  final AnkiRepository ankiRepository;
  final NoteContext noteContext;

  EditNoteBloc({@required this.noteRepository,
    @required this.ankiRepository,
    @required this.noteContext}) :
      assert(noteRepository != null),
      assert(ankiRepository != null);

  @override
  EditNoteState get initialState => LoadingAnkiInfo();

  @override
  Stream<EditNoteState> mapEventToState(EditNoteState currentState, EditNoteEvent event) async* {
    if (event is LoadAnkiInfo) {
      yield LoadingAnkiInfo();

      try {
        // TODO: get real anki info
        noteContext.decks = [
          AnkiDeck(
            id: "234",
            name: "新一代中文",
          ),
          AnkiDeck(
            id: "425",
            name: "Python",
          ),
        ];

        if (noteContext.note != null) {
          for(int i = 0; i < noteContext.decks.length; i++) {
            if (noteContext.decks[i].id == noteContext.note.deckId) {
              noteContext.deck = noteContext.decks[i];
              break;
            }
          }
        }

        if(noteContext.deck == null) {
          noteContext.deck = noteContext.decks[0];
        }

        noteContext.models = [
          AnkiNoteModel(
            id: "42",
            name: "Chinese-English",
            fields: ["Chinese", "Pronunciation", "English"],
          ),
          AnkiNoteModel(
            id: "22",
            name: "Term",
            fields: ["Term", "Definition"],
          )
        ];

        if(noteContext.note != null) {
          for(int i = 0; i < noteContext.models.length; i++) {
            if(noteContext.models[i].id == noteContext.note.modelId) {
              noteContext.model = noteContext.models[i];
              break;
            }
          }
        }

        if (noteContext.model == null) {
          noteContext.model = noteContext.models[0];
        }

        yield LoadedAnkiInfo();
      } catch (error) {
        print(error);
        yield FailedAnkiInfo(error: error);
      }
    }

    if (event is SaveNote) {
      yield SavingNote();
      try {
        print("Saving note");
        noteContext.renderNote();
        Note note = await noteRepository.saveNote(noteContext.note);
        if (noteContext.note.id == null) {
          noteContext.note.id = note.id;
        }
        yield SavedNote();
      } catch (error) {
        print(error.toString());
        yield SavingNoteFailed(error: error.toString());
      }
    }

    if (event is SendNote) {
      yield SendingNote();

      try {
        yield SendingNote();
        // TODO: send note to anki

      } catch (error) {
        yield FailedSendingNote(error: error);
      }
    }
  }
}