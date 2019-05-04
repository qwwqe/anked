import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anked/repository/repository.dart';
import 'package:anked/model/model.dart';
import 'package:anked/editnoteform/editnoteform.dart';

class EditNoteForm extends StatefulWidget {
  final NoteRepository noteRepository;
  final NoteContext noteContext;
  bool editable = true;

  EditNoteForm({@required this.noteRepository, @required this.noteContext, this.editable}) :
      assert(noteRepository != null),
      assert(noteContext != null);

  @override
  _EditNoteFormState createState() => _EditNoteFormState();
}

class _EditNoteFormState extends State<EditNoteForm> {
  EditNoteFormBloc _editNoteFormBloc;

  NoteRepository get _noteRepository => widget.noteRepository;
  NoteContext get _noteContext => widget.noteContext;
  bool get _editable => widget.editable;

  @override
  void initState() {
    _editNoteFormBloc = EditNoteFormBloc(
      noteRepository: _noteRepository,
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
  Widget build(BuildContext context) => BlocBuilder(
    bloc: _editNoteFormBloc,
    builder: (BuildContext context, EditNoteFormState state) {
      var formChildren = <Widget>[
        ListTile(
          title: Text("Deck"),
          trailing: DropdownButton<AnkiDeck>(
            value: _noteContext.deck,
            onChanged: _editable
                ? (deck) => _editNoteFormBloc.dispatch(ModifyDeck(deck: deck))
                : null,
            items: _noteContext.decks.map((deck) {
              return DropdownMenuItem<AnkiDeck>(
                value: deck,
                child: Text(deck.name),
              );
            }).toList(),
          ),
        ),
        ListTile(
          title: Text("Note Type"),
          trailing: DropdownButton<AnkiNoteModel>(
            value: _noteContext.model,
            onChanged: _editable
                ? (noteModel) => _editNoteFormBloc.dispatch(ModifyNoteModel(noteModel: noteModel))
                : null,
            items: _noteContext.models.map((noteModel) {
              return DropdownMenuItem<AnkiNoteModel>(
                value: noteModel,
                child: Text(noteModel.name),
              );
            }).toList(),
          ),
        ),
        Divider(),
      ];

      // TODO: look into using Slivers instead
      for(int i = 0; i < _noteContext.model.fields.length && i < _noteContext.controllers.length; i++) {
        formChildren.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 7, vertical: 0),
          child: TextField(
            enabled: _editable,
            decoration: InputDecoration(labelText: _noteContext.model.fields[i]),
            controller: _noteContext.controllers[i],
          ),
        ));
      }

      return ListView(
          children: formChildren,
      );
    }
  );


}