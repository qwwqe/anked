import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:anked/model/model.dart';

abstract class EditNoteFormEvent extends Equatable {
  EditNoteFormEvent([List props = const[]]) : super([props]);
}

class ModifyDeck extends EditNoteFormEvent {
  final AnkiDeck deck;

  ModifyDeck({@required this.deck}) :
        assert(deck != null),
        super([deck]);

  @override
  String toString() => "ModifyDeck";
}

class ModifyNoteModel extends EditNoteFormEvent {
  final AnkiNoteModel noteModel;

  ModifyNoteModel({@required this.noteModel}) :
        assert(noteModel != null),
        super([noteModel]);

  @override
  String toString() => "ModifyNoteType";
}

class ModifyField extends EditNoteFormEvent {
  final int fieldIndex;
  final String fieldValue;

  ModifyField({@required this.fieldIndex, this.fieldValue}) :
      assert(fieldIndex != null),
      assert(fieldValue != null),
      super([fieldIndex,fieldValue]);

  @override
  String toString() => "ModifyField $fieldIndex $fieldValue";
}