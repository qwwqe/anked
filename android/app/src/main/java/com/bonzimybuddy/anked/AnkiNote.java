package com.bonzimybuddy.anked;

public class AnkiNote {
    String id;
    String name;
    String fieldString;
    String modelId;

    AnkiNote(String id, String name, String modelId, String fieldString) {
        this.id = id;
        this.name = name;
        this.modelId = modelId;
        this.fieldString = fieldString;
    }
}
