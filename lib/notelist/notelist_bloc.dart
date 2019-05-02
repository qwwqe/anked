import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:anked/notelist/notelist.dart';
import 'package:anked/repository/repository.dart';

class NoteListBloc extends Bloc<NoteListEvent, NoteListState> {
  final AnkiRepository ankiRepository;
  final NoteRepository noteRepository;

  NoteListBloc({@required this.ankiRepository, @required this.noteRepository}) :
      assert(ankiRepository != null),
      assert(noteRepository != null);

  @override
  NoteListState get initialState => NoteListLoading();

  @override
  Stream<NoteListState> mapEventToState(NoteListState currentState, NoteListEvent event) async* {
    if(event is GetNoteList) {
      yield NoteListLoading();

      try {
        final noteList = await noteRepository.getNoteList();
        print(noteList.toString());
        yield NoteListLoaded(noteList: noteList);
      } catch (error) {
        yield NoteListFailure(error: error.toString());
      }
    }
  }
}
