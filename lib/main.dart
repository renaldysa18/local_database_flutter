import 'package:flutter/material.dart';
import 'package:local_database_flutter/src/ui/note_detail.dart';
import 'package:local_database_flutter/src/ui/note_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Note",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: NoteList(),
    );
  }
}

