import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:anked/model/model.dart';

abstract class EditNoteFormState extends Equatable {
  EditNoteFormState([List props = const []]) : super([props]);
}

class DeckChanged extends EditNoteFormState {
  final AnkiDeck deck;

  DeckChanged({@required this.deck}) :
        assert(deck != null),
        super([deck]);

  @override
  String toString() => "DeckChanged";
}

class NoteModelChanged extends EditNoteFormState {
  final AnkiNoteModel noteModel;

  NoteModelChanged({@required this.noteModel}) :
      assert(noteModel != null),
      super([noteModel]);

  @override
  String toString() => "NoteTypeChanged";
}

class FieldChanged extends EditNoteFormState {
  final int fieldIndex;
  final String fieldValue;
  final bool exists;

  FieldChanged({@required this.fieldIndex, @required this.fieldValue, this.exists = false}) :
      assert(fieldValue != null),
      assert(fieldIndex != null),
      super([fieldIndex, fieldValue]);

  @override
  String toString() => "FieldChanged";
}