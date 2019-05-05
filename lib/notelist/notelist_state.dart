import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:anked/model/model.dart';

abstract class NoteListState extends Equatable {
  NoteListState([List props = const []]) : super(props);
}

class NoteListLoading extends NoteListState {
  @override
  String toString() => "NoteListLoading";
}

class NoteListFailure extends NoteListState {
  final String error;

  NoteListFailure({@required this.error}) : super([error]);

  @override
  String toString() => "NoteListFailure: ${this.error}";
}

// All states below are rendered with the same Widget

class NoteListLoaded extends NoteListState {
  @override
  String toString() => "NoteListLoaded";
}

class NoteListRefreshed extends NoteListState {
  final Note note;

  NoteListRefreshed({this.note}) : super([note]);

  //@override
  //bool operator == (o) => false;

  @override
  String toString() => "NoteListRefreshed";
}

class DeletingNote extends NoteListState {
  @override
  String toString() => "DeletingNote";
}

class NoteDeleted extends NoteListState {
  @override
  String toString() => "DeletedNote";
}

class NoteDeletionFailure extends NoteListState {
  final String error;

  NoteDeletionFailure({@required this.error}) : super([error]);

  @override
  String toString() => "NoteDelitionFailure";
}

class ReturnedFromNoteSaved extends NoteListState {
  @override
  String toString() => "ReturnedFromNoteSaved";
}