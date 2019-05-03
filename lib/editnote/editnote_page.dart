import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anked/repository/repository.dart';
import 'package:anked/notelist/notelist.dart';
import 'package:anked/common/common.dart';
import 'package:bloc/bloc.dart';

class EditNotePage extends StatefulWidget {
  final AnkiRepository ankiRepository;
  final NoteRepository noteRepository;
  Map<String, dynamic> note;

  EditNotePage({Key key, this.note, @required this.ankiRepository, @required this.noteRepository}) :
        assert(ankiRepository != null),
        assert(noteRepository != null),
        super(key: key);

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  bool isNewNote;

  AnkiRepository get _ankiRepository => widget.ankiRepository;
  NoteRepository get _noteRepository => widget.noteRepository;
  Map<String, dynamic> get _note => widget.note;

  @override
  void initState() {
    isNewNote = _note == null ? true : false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isNewNote ? Text("New note") : Text("Edit note"),
      ),
      body: isNewNote ? Text("New note") : Text(_note.toString()),//BlocBuilder(),
    );
  }
}
