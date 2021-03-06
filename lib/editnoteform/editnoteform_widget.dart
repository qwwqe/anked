import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anked/repository/repository.dart';
import 'package:anked/model/model.dart';
import 'package:anked/editnoteform/editnoteform.dart';
import 'package:anked/editnote/editnote.dart';
import 'package:anked/settings/settings.dart';

class EditNoteForm extends StatefulWidget {
  final NoteRepository noteRepository;
  final AnkiRepository ankiRepository;
  final NoteContext noteContext;
  bool editable = true;

  EditNoteForm({@required this.noteRepository, @required this.ankiRepository, @required this.noteContext, this.editable}) :
      assert(noteRepository != null),
      assert(noteContext != null);

  @override
  _EditNoteFormState createState() => _EditNoteFormState();
}

class _EditNoteFormState extends State<EditNoteForm> {
  EditNoteFormBloc _editNoteFormBloc;

  AnkiRepository get _ankiRepository => widget.ankiRepository;
  NoteRepository get _noteRepository => widget.noteRepository;
  NoteContext get _noteContext => widget.noteContext;
  bool get _editable => widget.editable;

  @override
  void initState() {
    _editNoteFormBloc = EditNoteFormBloc(
      editNoteBloc: BlocProvider.of<EditNoteBloc>(context),
      noteRepository: _noteRepository,
      ankiRepository: _ankiRepository,
      noteContext: _noteContext,
    );
    _editNoteFormBloc.dispatch(ModifyNoteModel(noteModel: _noteContext.model));
    super.initState();
  }

  @override
  void dispose() {
    _editNoteFormBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener(
    bloc: BlocProvider.of<SettingsBloc>(context),
    listener: (BuildContext context, SettingsState state) {
      if (state is SettingsLoaded) {
        AnkiDeck newDeck;
        if(state.deckId != null) {
          for (int i = 0; i < _noteContext.decks.length; i++) {
            if (_noteContext.decks[i].id == state.deckId) {
              newDeck = _noteContext.decks[i];
              break;
            }
          }
        }

        if (newDeck != null) {
          _editNoteFormBloc.dispatch(ModifyDeck(deckId: newDeck.id));
        }

        AnkiNoteModel newNoteModel;
        if(state.noteModelId != null) {
          for (int i = 0; i < _noteContext.models.length; i++) {
            if(_noteContext.models[i].id == state.noteModelId) {
              newNoteModel = _noteContext.models[i];
              break;
            }
          }
        }

        if (newNoteModel != null) {
          _editNoteFormBloc.dispatch(ModifyNoteModel(noteModel: newNoteModel));
        }
      }
    },
    child: BlocBuilder(
      bloc: _editNoteFormBloc,
      builder: (BuildContext context, EditNoteFormState state) {
        bool firstFieldExists = false;
        if(state is FieldChanged && state.exists) {
          firstFieldExists = true;
        }

        var formChildren = <Widget>[
          // TODO: make dropdown index notemodel id
          ListTile(
            title: Text("Note Type"),
            trailing: DropdownButton<AnkiNoteModel>(
              value: _noteContext.model,
              onChanged: _editable
                  ? (noteModel) {
                    _editNoteFormBloc.dispatch(ModifyNoteModel(noteModel: noteModel));
                    BlocProvider.of<SettingsBloc>(context).dispatch(SetPreferredNoteModel(noteModelId: noteModel.id));
                  }
                  : null,
              items: _noteContext.models.map((noteModel) {
                return DropdownMenuItem<AnkiNoteModel>(
                  value: noteModel,
                  child: Text(noteModel.name),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: Text("Deck"),
            trailing: DropdownButton<String>(
              value: _noteContext.deck.id,
              onChanged: _editable
                  ? (deckId) {
                _editNoteFormBloc.dispatch(ModifyDeck(deckId: deckId));
                BlocProvider.of<SettingsBloc>(context).dispatch(SetPreferredDeck(deckId: deckId));
              }
                  : null,
              items: _noteContext.decks.map((deck) {
                return DropdownMenuItem<String>(
                  value: deck.id,
                  child: Text(deck.name),
                );
              }).toList(),
            ),
          ),
          Divider(),
       ];

        // TODO: look into using Slivers instead
        for(int i = 0; i < _noteContext.model.fields.length && i < _noteContext.controllers.length; i++) {
          TextStyle textStyle;
          if(i == 0 && firstFieldExists) {
            textStyle = TextStyle(
              backgroundColor: Colors.red[200],
            );
          } else {
            textStyle = TextStyle();
          }

          formChildren.add(Padding(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 0),
            child: TextField(
              enabled: _editable,
              maxLines: null,
              decoration: InputDecoration(
                  labelText: _noteContext.model.fields[i],
                  labelStyle: TextStyle(backgroundColor: Colors.transparent),
                  //fillColor: Colors.red[200],
                  //filled: i == 0 && firstFieldExists,
              ),
              style: textStyle,
              controller: _noteContext.controllers[i],
            ),
          ));
        }

        return ListView(
          children: formChildren,
        );
      }
    ),
  );
}