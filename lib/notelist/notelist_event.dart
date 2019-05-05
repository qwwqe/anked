import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:anked/model/model.dart';

abstract class NoteListEvent extends Equatable {
  NoteListEvent([List props = const []]) : super(props);
}

class GetNoteList extends NoteListEvent {
  @override
  String toString() => "GetNoteList";
}

class RefreshNoteList extends NoteListEvent {
  final Note note;

  RefreshNoteList({this.note}) : super([note]);

  @override
  String toString() => "RefreshNoteList";
}

class DeleteNote extends NoteListEvent {
  final Note note;

  DeleteNote({@required this.note}) : assert(note != null), super([note]);
}

class ReturnFromNoteSaved extends NoteListEvent {
  @override
  String toString() => "ReturnFromNoteSaved";
}