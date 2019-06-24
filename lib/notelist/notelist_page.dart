import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anked/repository/repository.dart';
import 'package:anked/notelist/notelist.dart';
import 'package:anked/common/common.dart';
import 'package:anked/editnote/editnote.dart';
import 'package:bloc/bloc.dart';
import 'package:anked/model/model.dart';
import 'package:anked/settings/settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:math';

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
  List<Note> filteredNoteList;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Timer notificationTimer;

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

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    var initializationSettings = InitializationSettings(initializationSettingsAndroid, null);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

    notificationTimer = Timer.periodic(Duration(hours: 1), notificationTimerCallback);

    super.initState();
  }

  @override
  void dispose() {
    _noteListBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("anked"),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditNotePage(
                      noteRepository: _noteRepository,
                      ankiRepository: _ankiRepository,
                    ),
                  ),
                ).then((r) {
                  _noteListBloc.dispatch(GetNoteList());
                });
              },
            )
          ],
        ),
        body: BlocListener(
          bloc: _noteListBloc,
          listener: (BuildContext context, NoteListState state) {
            if (state is NoteListFailure) {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text("Failed loading notes.")));
            }

            if (state is NoteDeleted) {
              _noteListBloc.dispatch(GetNoteList());
            }

            if (state is ReturnedFromNoteSaved) {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text("Note sent to Anki.")));
            }
          },
          child: BlocBuilder(
              bloc: _noteListBloc,
              builder: (BuildContext context, NoteListState state) {
                if (state is NoteListLoading) {
                  return LoadingIndicator();
                }

                if (state is NoteListFailure) {
                  return Center(
                    child: Icon(Icons.error),
                  );
                }

                // All states below are rendered with the same Widget
                // TODO: failure states

                if (noteList.length == 0) {
                  return Center(
                    child: Text("You've synced all your cards to Anki!")
                  );
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
                        ).then((r) {
                          //if(r) {
                          //  _noteListBloc.dispatch(ReturnFromNoteSaved());
                          //}
                          _noteListBloc.dispatch(GetNoteList());
                        });
                      },
                    ),
                  ),
                );
              }
          ),
        ),
/*
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
              ).then((r) {
                //if(r) {
                //  _noteListBloc.dispatch(ReturnFromNoteSaved());
                //}
                _noteListBloc.dispatch(GetNoteList());
              });
            },
            child: Icon(Icons.add),
        ),
*/
    );
  }

  Future onSelectNotification(String noteId) async {
    if (noteId == null) {
      return;
    }

    debugPrint('Notification noteId: ' + noteId);

    Note note;
    for(int i = 0; i < noteList.length; i++) {
      if(noteList[i].id == int.parse(noteId)) {
        note = noteList[i];
        break;
      }
    }

    if (note == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNotePage(
          noteRepository: _noteRepository,
          ankiRepository: _ankiRepository,
          note: note,
        ),
      ),
    ).then((r) => _noteListBloc.dispatch(GetNoteList()));
  }

  void notificationTimerCallback(Timer t) async {
      if(noteList.length > 0) {
        await flutterLocalNotificationsPlugin.cancelAll();

        var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
            'DOOBLE',
            'DABBLE',
            'DIBBLE',
            importance: Importance.Max,
            priority: Priority.High,
        );

        var platformChannelSpecifics = new NotificationDetails(
            androidPlatformChannelSpecifics,
            null,
        );
        
        int noteIndex = Random().nextInt(noteList.length);
        await flutterLocalNotificationsPlugin.show(
            0, '順便輸入一下Anki', '尚待輸入: ' + noteList[noteIndex].note['fields'][0]['value'], platformChannelSpecifics,
            payload: noteList[noteIndex].id.toString()
        );
      }
    }
}