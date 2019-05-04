import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class EditNoteEvent extends Equatable {
  EditNoteEvent([List props = const[]]) : super(props);
}

class LoadAnkiInfo extends EditNoteEvent {
  @override
  String toString() => "LoadAnkiInfo";
}

class SaveNote extends EditNoteEvent {
  @override
  String toString() => "SaveNote";
}

class SendNote extends EditNoteEvent {
  final Map<String, dynamic> note;

  SendNote({@required this.note}) : assert(note != null);
}