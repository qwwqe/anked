package com.bonzimybuddy.anked;

import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MainActivity extends FlutterActivity {
  private final static String CHANNEL = "com.bonzimybuddy.anked/anki";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, Result result) {
                if(call.method.equals("getPermissions")) {

                }

                if(call.method.equals("getDecks")) {
                  HashMap<Long, String> decks = getDecks();
                  if(decks.isEmpty()) {
                    result.error("Error fetching decks", null, null);
                  } else {
                    result.success(decks);
                  }
                }

                if(call.method.equals("getModels")) {
                  ArrayList<HashMap<String, String>> models = getModels();
                  if(models.isEmpty()) {
                    result.error("Error fetching models", null, null);
                  } else {
                    result.success(models);
                  }
                }

                if(call.method.equals("saveNote")) {
                  String modelId = call.argument("modelId");
                  String deckId = call.argument("deckId");
                  String fieldString = call.argument("fieldString");

                  int rows = saveNote(modelId, deckId, fieldString);

                  /*
                  AnkiNote note = new AnkiNote(null, null, "1554320620450", null);
                  String[] fields = {
                          "隨便", "ㄙㄨㄟˊㄅㄧㄢˋ", "Whatever", "隨便妳", "我隨便", "隨便吃",
                  };
                  note.fieldString = TextUtils.join("\u001f", fields);
                  int rows = saveNote(note, "1525493682831");
                  */

                  Log.d("PLATFORM", rows + " rows inserted");
                  if (rows != 1) {
                    result.error("Error saving note", null, null);
                  } else {
                    result.success(rows);
                  }
                }

                if(call.method.equals("checkCardExistence")) {
                  String modelId = call.argument("modelId");
                  String deckName = call.argument("deckName");
                  String firstFieldName = call.argument("firstFieldName");
                  String firstFieldValue = call.argument("firstFieldValue");

                  boolean exists = checkCardExistence(modelId, deckName, firstFieldName, firstFieldValue);

                  Log.d("PLATFORM", "Exists? " + exists);
                  result.success(exists);
                }
              }
            }
    );
  }

  private HashMap<Long, String> getDecks() {
    HashMap<Long, String> decks = new HashMap<>();

    Cursor cursor = getContentResolver().query(FlashCardsContract.Deck.CONTENT_ALL_URI, null, null, null, null);
    if (cursor.moveToFirst()) {
      do {
        long deckId = cursor.getLong(cursor.getColumnIndex(FlashCardsContract.Deck.DECK_ID));
        String deckName = cursor.getString(cursor.getColumnIndex(FlashCardsContract.Deck.DECK_NAME));
        decks.put(deckId, deckName);
      } while(cursor.moveToNext());
    }

    return decks;
  }

  private ArrayList<HashMap<String, String>> getModels() {
    ArrayList<HashMap<String, String>> models = new ArrayList<>();

    Cursor cursor = getContentResolver().query(FlashCardsContract.Model.CONTENT_URI, null, null, null, null);
    if (cursor.moveToFirst()) {
      do {
        long modelId = cursor.getLong(cursor.getColumnIndex(FlashCardsContract.Model._ID));
        String modelName = cursor.getString(cursor.getColumnIndex(FlashCardsContract.Model.NAME));
        String fieldNames = cursor.getString(cursor.getColumnIndex(FlashCardsContract.Model.FIELD_NAMES));
        HashMap<String, String> modelMap = new HashMap<>();
        modelMap.put("id", String.valueOf(modelId));
        modelMap.put("name", modelName);
        modelMap.put("fieldString", fieldNames);
        models.add(modelMap);
      } while(cursor.moveToNext());
    }

    return models;
  }

  private boolean checkCardExistence(String modelId, String deckName, String firstFieldName, String firstFieldValue) {
    String selection = String.format("mid:\"%s\" deck:\"%s\" \"%s\":\"%s\"", modelId, deckName, firstFieldName, firstFieldValue);
    Cursor cursor = getContentResolver().query(FlashCardsContract.Note.CONTENT_URI_V2, null, selection, null, null);
    if(cursor.moveToFirst()) {
      return true;
    }

    return false;
  }

  private int saveNote(String modelId, String deckId, String fieldString) {
    //ContentValues values = new ContentValues();
    //values.put(FlashCardsContract.Deck.DECK_ID, deckId);
    //getContentResolver().update(FlashCardsContract.Deck.CONTENT_SELECTED_URI, values, null,null);

    Uri deckUri = FlashCardsContract.Note.CONTENT_URI.
            buildUpon().appendQueryParameter(FlashCardsContract.Note.DECK_ID_QUERY_PARAM, deckId).build();

    ContentValues values = new ContentValues();
    values.put(FlashCardsContract.Note.MID, modelId);
    values.put(FlashCardsContract.Note.FLDS, fieldString);
    ContentValues[] valuesList = { values };

    return getContentResolver().bulkInsert(deckUri, valuesList);
  }
}
