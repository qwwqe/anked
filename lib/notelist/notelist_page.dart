import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anked/repository/repository.dart';
import 'package:anked/notelist/notelist.dart';
import 'package:anked/common/common.dart';
import 'package:anked/editnote/editnote.dart';
import 'package:bloc/bloc.dart';

class NoteListPage extends StatefulWidget {
  final AnkiRepository ankiRepository;
  final NoteRepository noteRepository;

  NoteListPage({Key key, @required this.ankiRepository, @required this.noteRepository}) :
      assert(ankiRepository != null),
      assert(noteRepository != null),
      super(key: key);

  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  NoteListBloc _noteListBloc;

  AnkiRepository get _ankiRepository => widget.ankiRepository;
  NoteRepository get _noteRepository => widget.noteRepository;

  @override
  void initState() {
    _noteListBloc = NoteListBloc(
        ankiRepository: _ankiRepository,
        noteRepository: _noteRepository,
    );
    _noteListBloc.dispatch(GetNoteList());
    super.initState();
  }

  @override
  void dispose() {
    _noteListBloc.dispose();
    super.dispose();
  }

  // TODO: check if notelist will get updated properly without this
  //@override
  //void didUpdateWidget(Widget oldWidget) {
  //  _noteListBloc.dispatch(GetNoteList());
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("anked"),
        ),
        body: BlocBuilder(
          bloc: _noteListBloc,
          builder: (BuildContext context, NoteListState state) {
            if (state is NoteListLoading) {
              return LoadingIndicator();
            }

            if (state is NoteListLoaded) {

              return ListView.builder(
                itemCount: state.noteList.length,
                itemBuilder: (BuildContext, int index) => Card( // TODO: use Row()
                  child: ListTile(
                    title: Text(state.noteList[index].note['fields'][0]['value']),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditNotePage(
                            noteRepository: _noteRepository,
                            ankiRepository: _ankiRepository,
                            note: state.noteList[index],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            if (state is NoteListFailure) {
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text("Failed loading notes.")));

              return Center(
                child: Icon(Icons.error),
              );
            }
          }
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditNotePage(
                    noteRepository: _noteRepository,
                    ankiRepository: _ankiRepository,
                ),
              ),
            ),
            child: Icon(Icons.add),
        ),
    );
  }
}