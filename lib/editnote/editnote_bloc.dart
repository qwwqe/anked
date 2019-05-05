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
  Stream<EditNoteState> mapEventToState(EditNoteEvent event) async* {
    if (event is LoadAnkiInfo) {
      yield LoadingAnkiInfo();

      try {
        AnkiInfo ankiInfo = await ankiRepository.getAnkiInfo();
        noteContext.decks = ankiInfo.decks;
        noteContext.models = ankiInfo.noteModels;
        /*
        noteContext.decks = [
          AnkiDeck(
            id: "1525493682831",
            name: "嶄新一代中文",
          ),
          AnkiDeck(
            id: "1555322735260",
            name: "Python",
          ),
        ];
        */

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

        /*
        noteContext.models = [
          AnkiNoteModel(
            id: "1525396147269",
            name: "Cloze Definition",
            fields: ["Text", "Word", "Pronunciation", "Definition", "Picture"],
          ),
          AnkiNoteModel(
            id: "1554320620450",
            name: "Term",
            fields: ["Chinese", "Pronunciation", "English", "Example", "Example", "Example"],
          )
        ];
        */

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
        noteContext.renderNote();
        var ankiNote = AnkiNote(
          modelId: noteContext.note.modelId,
          deckId: noteContext.note.deckId,
        );
        // TODO: these note models need cleaning up
        var fields = List<String>();
        noteContext.note.note['fields'].forEach((f) => fields.add(f['value']));
        ankiNote.loadFieldStringFromList(fields);

        print(fields);
        print(ankiNote.fieldString);

        int success = await ankiRepository.addNote(ankiNote);
        if (success < 1) {
          throw("Failed to save note");
        }

        await noteRepository.deleteNote(noteContext.note);

        yield SentNote();
      } catch (error) {
        yield SendingNoteFailed(error: error);
      }
    }
  }
}