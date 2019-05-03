import 'package:equatable/equatable.dart';
import 'package:anked/model/model.dart';
import 'package:meta/meta.dart';

abstract class EditNoteState extends Equatable {
  EditNoteState([List props = const []]) : super(props);
}

class LoadingAnkiInfo extends EditNoteState {
  @override
  String toString() => "LoadingAnkiInfo";
}

class LoadedAnkiInfo extends EditNoteState {
  @override
  String toString() => "LoadedAnkiInfo";
}

class FailedAnkiInfo extends EditNoteState {
  final String error;

  FailedAnkiInfo({@required this.error}) : assert(error != null), super([error]);

  @override
  String toString() => "FailedAnkiInfo";
}

class SendingNote extends EditNoteState {
  @override
  String toString() => "SendingNote";
}

class FailedSendingNote extends EditNoteState {
  final String error;

  FailedSendingNote({@required this.error}) : assert(error != null), super([error]);

  @override
  String toString() => "FailedSendingNote";
}

class SentNote extends EditNoteState {
  @override
  String toString() => "SentNote";
}