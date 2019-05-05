import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anked/repository/repository.dart';
import 'package:anked/notelist/notelist.dart';
import 'package:anked/common/common.dart';
import 'package:anked/editnote/editnote.dart';
import 'package:bloc/bloc.dart';
import 'package:anked/model/model.dart';

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
  List<Note> noteList;

  AnkiRepository get _ankiRepository => widget.ankiRepository;
  NoteRepository get _noteRepository => widget.noteRepository;

  @override
  void initState() {
    noteList = List<Note>();
    _noteListBloc = NoteListBloc(
        ankiRepository: _ankiRepository,
        noteRepository: _noteRepository,
        noteList: noteList,
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

            if (state is NoteListFailure) {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text("Failed loading notes.")));

              return Center(
                child: Icon(Icons.error),
              );
            }

            // All states below are rendered with the same Widget
            // TODO: failure states

            if (state is NoteDeleted) {
              _noteListBloc.dispatch(GetNoteList());
            }

            // TODO: figure out long press drop down menu...
            return ListView.builder(
                itemCount: noteList.length,
                itemBuilder: (BuildContext context, int index) => Card(
                    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                    child: ListTile(
                      title: Text(noteList[index].note['fields'][0]['value']),
                      //subtitle: Text(noteList[index].note['fields'][2]['value']), // TODO: check array bounds...
                      trailing: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () => _noteListBloc.dispatch(DeleteNote(note: noteList[index])),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditNotePage(
                              noteRepository: _noteRepository,
                              ankiRepository: _ankiRepository,
                              note: noteList[index],
                            ),
                          ),
                        ).then((r) => _noteListBloc.dispatch(GetNoteList()));
                      },
                    ),
              ),
            );
          }
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNotePage(
                    noteRepository: _noteRepository,
                    ankiRepository: _ankiRepository,
                  ),
                ),
              ).then((r) => _noteListBloc.dispatch(GetNoteList()));
            },
            child: Icon(Icons.add),
        ),
    );
  }
}