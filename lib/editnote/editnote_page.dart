import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anked/repository/repository.dart';
import 'package:anked/notelist/notelist.dart';
import 'package:anked/editnote/editnote.dart';
import 'package:anked/common/common.dart';
import 'package:bloc/bloc.dart';
import 'package:anked/model/model.dart';
import 'package:anked/editnoteform/editnoteform.dart';

class EditNotePage extends StatefulWidget {
  final AnkiRepository ankiRepository;
  final NoteRepository noteRepository;
  final Note note;

  EditNotePage({Key key, this.note, @required this.ankiRepository, @required this.noteRepository}) :
        assert(ankiRepository != null),
        assert(noteRepository != null),
        super(key: key);

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  EditNoteBloc editNoteBloc;
  NoteContext noteContext;

  bool isNewNote;
  String deckName;
  String noteType;

  AnkiRepository get _ankiRepository => widget.ankiRepository;
  NoteRepository get _noteRepository => widget.noteRepository;
  Note get _note => widget.note;

  @override
  void initState() {
    isNewNote = _note == null ? true : false;
    noteContext = NoteContext();
    noteContext.note = _note;

    editNoteBloc = EditNoteBloc(
      ankiRepository: _ankiRepository,
      noteRepository: _noteRepository,
      noteContext: noteContext,
    );
    editNoteBloc.dispatch(LoadAnkiInfo()); // TODO: put this in main page to speed up first load time
    super.initState();
  }

  @override
  void dispose() {
    editNoteBloc.dispose();
    noteContext.disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isNewNote ? Text("New note") : Text("Edit note"),
      ),
      body: BlocBuilder(
        bloc: editNoteBloc,
        builder: (BuildContext context, EditNoteState state) {
          if (state is LoadingAnkiInfo) {
            return LoadingIndicator();
          }

          if (state is FailedAnkiInfo) {
            return Center(
              child: Icon(Icons.error),
            );
          }

          if (state is SentNote) {
            // TODO: delete note and go back
          }

          // All states should ultimately display the EditNoteForm

          return EditNoteForm(
            noteRepository: _noteRepository,
            noteContext: noteContext,
            editable: !(state is SendingNote || state is SavingNote),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => editNoteBloc.dispatch(SaveNote()),
        child: Icon(Icons.save),
      ),
    );
      //isNewNote ? Text("New note") : Text(_note.toString()),//BlocBuilder(),
  }
}
