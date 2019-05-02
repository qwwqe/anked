import 'package:flutter/material.dart';
import 'package:anked/repository/repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MainApp(ankiRepository: AnkiRepository()));
}

class MainApp extends StatefulWidget {
  final AnkiRepository ankiRepository;

  MainApp({Key key, @required this.ankiRepository}) :
        assert(ankiRepository != null),
        super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("anked"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          ],
        ),
      ),
    );
  }
}
