import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anked/repository/repository.dart';
import 'package:anked/notelist/notelist.dart';
import 'package:anked/editnote/editnote.dart';
import 'package:anked/common/common.dart';
import 'package:bloc/bloc.dart';
import 'package:anked/model/model.dart';
import 'package:anked/editnoteform/editnoteform.dart';
import 'package:meta/meta.dart';
import 'package:anked/settings/settings.dart';

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
  SettingsBloc _settingsBloc;

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

    _settingsBloc = SettingsBloc();
    if (isNewNote) {
      print("NEW NOTE");
      _settingsBloc.dispatch(LoadSettings());
    }

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
    _settingsBloc.dispose();
    noteContext.disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isNewNote ? Text("New note") : Text("Edit note"),
        actions: [
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () => editNoteBloc.dispatch(SendNote()),
          )
        ],
      ),
      body: BlocListener(
        bloc: editNoteBloc,
        listener: (BuildContext context, EditNoteState state) {
          if (state is FailedAnkiInfo) {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Failed to retrieve deck data from Anki."),
            ));
          }

          if (state is SavedNote) {
//            Scaffold.of(context).showSnackBar(SnackBar(
//                content: Text("Note saved."),
//            ));
          }

          if (state is SavingNoteFailed) {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Saving note failed."),
            ));
          }

          if (state is SendingNoteFailed) {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Sending note to Anki failed."),
            ));
          }

          if (state is SentNote) {
            Navigator.pop(context, true);
          }
        },
        child: BlocBuilder(
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

              // All other states should ultimately display the EditNoteForm

              return BlocProviderTree(
                blocProviders: [
                  BlocProvider<SettingsBloc>(bloc: _settingsBloc),
                  BlocProvider<EditNoteBloc>(bloc: editNoteBloc),
                ],
                child: EditNoteForm(
                  ankiRepository: _ankiRepository,
                  noteRepository: _noteRepository,
                  noteContext: noteContext,
                  editable: !(state is SendingNote || state is SavingNote),
                ),
              );
            }
        ),
      ),
/*      floatingActionButton: FloatingActionButton(
        onPressed: () => editNoteBloc.dispatch(SaveNote()),
        child: Icon(Icons.save),
      ),*/
    );
      //isNewNote ? Text("New note") : Text(_note.toString()),//BlocBuilder(),
  }
}
