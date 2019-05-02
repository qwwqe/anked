import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class NoteListEvent extends Equatable {
  NoteListEvent([List props = const []]) : super(props);
}

class GetNoteList extends NoteListEvent {
  @override
  String toString() => "GetNoteList";
}