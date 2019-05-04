import 'package:equatable/equatable.dart';
import 'package:anked/model/model.dart';
import 'package:meta/meta.dart';

abstract class EditNoteState extends Equatable {
  EditNoteState([List props = const []]) : super(props);
}

// The following three states do not correspond to a Form widget
// (ie, should not be rendered as EditNoteForm)

class LoadingAnkiInfo extends EditNoteState {
  @override
  String toString() => "LoadingAnkiInfo";
}

class FailedAnkiInfo extends EditNoteState {
  final String error;

  FailedAnkiInfo({@required this.error}) : assert(error != null), super([error]);

  @override
  String toString() => "FailedAnkiInfo";
}

class SentNote extends EditNoteState {
  @override
  String toString() => "SentNote";
}

// All classes below do correspond to a Form widget

class LoadedAnkiInfo extends EditNoteState {
  @override
  String toString() => "LoadedAnkiInfo";
}

class SendingNote extends EditNoteState {
  @override
  String toString() => "SendingNote";
}

class SendingNoteFailed extends EditNoteState {
  final String error;

  SendingNoteFailed({@required this.error}) : assert(error != null), super([error]);

  @override
  String toString() => "FailedSendingNote";
}

class SavingNote extends EditNoteState {
  @override
  String toString() => "SavingNote";
}

class SavedNote extends EditNoteState {
  @override
  String toString() => "SavedNote";
}

class SavingNoteFailed extends EditNoteState {
  final String error;

  SavingNoteFailed({@required this.error}) : assert (error != null), super([error]);

  @override
  String toString() => "SavingNoteFailed";
}