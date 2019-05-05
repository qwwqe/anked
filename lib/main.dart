import 'package:flutter/material.dart';
import 'package:anked/repository/repository.dart';
import 'package:bloc/bloc.dart';
import 'package:anked/common/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anked/notelist/notelist.dart';
import 'package:flutter/services.dart';

class PrintTransitionDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    debugPrint(transition.toString());
  }
}

void main() async {
  BlocSupervisor().delegate = PrintTransitionDelegate();

  // TODO: this seems like the wrong place to do this. Why not put it in the widget?
  var ankiRepository = AnkiRepository();
  var noteRepository = NoteRepository();

  runApp(MainApp(ankiRepository: ankiRepository, noteRepository: noteRepository));
}

class MainApp extends StatefulWidget {
  final AnkiRepository ankiRepository;
  final NoteRepository noteRepository;

  MainApp({Key key, @required this.ankiRepository, @required this.noteRepository}) :
        assert(ankiRepository != null),
        assert(noteRepository != null),
        super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  static const platform = const MethodChannel('com.bonzimybuddy.anked/anki');

  AnkiRepository get _ankiRepository => widget.ankiRepository;
  NoteRepository get _noteRepository => widget.noteRepository;

  @override
  void initState() {
    _ankiRepository.setMethodChannel(platform);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: "anked",
      home: NoteListPage(
          ankiRepository: _ankiRepository,
          noteRepository: _noteRepository,
      ),
  );

}
