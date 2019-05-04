import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:anked/notelist/notelist.dart';
import 'package:anked/repository/repository.dart';
import 'package:anked/model/model.dart';

class NoteListBloc extends Bloc<NoteListEvent, NoteListState> {
  final AnkiRepository ankiRepository;
  final NoteRepository noteRepository;
  final List<Note> noteList;

  NoteListBloc({@required this.ankiRepository, @required this.noteRepository,
      @required this.noteList}) :
      assert(ankiRepository != null),
      assert(noteRepository != null),
      assert(noteList != null);

  @override
  NoteListState get initialState => NoteListLoading();

  @override
  Stream<NoteListState> mapEventToState(NoteListEvent event) async* {
    if(event is GetNoteList) {
      yield NoteListLoading();

      try {
        noteList.clear();
        noteList.addAll(await noteRepository.getNoteList());
        yield NoteListLoaded();
      } catch (error) {
        yield NoteListFailure(error: error.toString());
      }
    }

    if(event is RefreshNoteList) {
      yield NoteListRefreshed();
    }

    if(event is DeleteNote) {
      yield DeletingNote();

      try {
        await noteRepository.deleteNote(event.note);
        yield NoteDeleted();
      } catch(error) {
        yield NoteDeletionFailure(error: error.toString());
      }
    }
  }
}
