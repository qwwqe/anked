import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class NoteListState extends Equatable {
  NoteListState([List props = const []]) : super(props);
}

class NoteListLoading extends NoteListState {
  @override
  String toString() => "NoteListLoading";
}

class NoteListLoaded extends NoteListState {
  final List<Map<String, dynamic>> noteList;

  NoteListLoaded({@required this.noteList}) : assert(noteList != null), super([noteList]);

  @override
  String toString() => "NoteListLoaded";
}

class NoteListFailure extends NoteListState {
  final String error;

  NoteListFailure({@required this.error}) : super([error]);

  @override
  String toString() => "NoteListFailure: ${this.error}";
}