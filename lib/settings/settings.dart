import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsEvent extends Equatable {
  SettingsEvent([List props = const []]) : super([props]);
}

class SetPreferredDeck extends SettingsEvent {
  final String deckId;

  SetPreferredDeck({@required this.deckId}) :
        assert(deckId != null), super([deckId]);

  @override
  String toString() => "SetPreferredDeck";
}

class SetPreferredNoteModel extends SettingsEvent {
  final String noteModelId;

  SetPreferredNoteModel({@required this.noteModelId}) :
      assert(noteModelId != null), super([noteModelId]);

  @override
  String toString() => "SetPreferredNoteModel";
}

class LoadSettings extends SettingsEvent {
  @override
  String toString() => "LoadSettings";
}

// STATE

abstract class SettingsState extends Equatable {
  SettingsState([List props = const[]]) : super([props]);
}

class SettingsInit extends SettingsState {
  @override
  String toString() => "SettingsInit";
}

class SettingsSaved extends SettingsState {
  @override
  String toString() => "SettingsSaved";
}

class SettingsFailed extends SettingsState {
  @override
  String toString() => "SettingsFailed";
}

class SettingsLoading extends SettingsState {
  @override
  String toString() => "SettingsLoading";
}

class SettingsLoaded extends SettingsState {
  final String deckId;
  final String noteModelId;

  SettingsLoaded({@required this.deckId, @required this.noteModelId}) :
      assert(deckId != null),
      assert(noteModelId != null),
      super([deckId, noteModelId]);
}

// BLOC

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static final String DECK_ID = "defaultDeckId";
  static final String MODEL_ID = "defaultModelId";

  SettingsState get initialState => SettingsInit();

  Stream<SettingsState> mapEventToState(SettingsEvent event) async*{
    if(event is SetPreferredDeck) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(DECK_ID, event.deckId);
      yield SettingsSaved();
    }

    if(event is SetPreferredNoteModel) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(MODEL_ID, event.noteModelId);
      yield SettingsSaved();
    }

    if(event is LoadSettings) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String deckId = "";
      String modelId = "";

      if(prefs.containsKey(DECK_ID)) {
        deckId = prefs.getString(DECK_ID);
      }

      if(prefs.containsKey(MODEL_ID)) {
        modelId = prefs.getString(MODEL_ID);
      }

      yield SettingsLoaded(deckId: deckId, noteModelId: modelId);
    }
  }
}