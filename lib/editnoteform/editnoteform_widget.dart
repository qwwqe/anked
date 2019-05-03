import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anked/repository/repository.dart';
import 'package:anked/model/model.dart';
import 'package:anked/editnoteform/editnoteform.dart';

class EditNoteForm extends StatefulWidget {
  final NoteRepository noteRepository;
  final NoteContext noteContext;

  EditNoteForm({@required this.noteRepository, this.noteContext}) :
      assert(noteRepository != null),
      assert(noteContext != null);

  @override
  _EditNoteFormState createState() => _EditNoteFormState();
}

class _EditNoteFormState extends State<EditNoteForm> {
  EditNoteFormBloc _editNoteFormBloc;

  NoteRepository get _noteRepository => widget.noteRepository;
  NoteContext get _noteContext => widget.noteContext;

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
            onChanged: (deck) => _editNoteFormBloc.dispatch(ModifyDeck(deck: deck)),
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
            onChanged: (noteModel) => _editNoteFormBloc.dispatch(ModifyNoteModel(noteModel: noteModel)),
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

      for(int i = 0; i < _noteContext.model.fields.length && i < _noteContext.controllers.length; i++) {
        formChildren.add(TextFormField(
          decoration: InputDecoration(labelText: _noteContext.model.fields[i]),
          controller: _noteContext.controllers[i],
        ));
      }

      return Form(
        child: Column(
          children: formChildren,
        ),
      );
    }
  );


}