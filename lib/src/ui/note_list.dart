import 'package:flutter/material.dart';
import 'package:local_database_flutter/src/model/note_model.dart';
import 'package:local_database_flutter/src/ui/note_detail.dart';
import 'package:local_database_flutter/src/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  List<NoteModel> _listNote;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (_listNote == null) {
      _listNote = List<NoteModel>();
      print('update list');
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Note'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('fab tap');
          navigateToDetail(NoteModel('', '', 2), 'Add Note');
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    getPriorityColor(this._listNote[index].priority),
                child: getPriorityIcon(this._listNote[index].priority),
              ),
              title: Text(
                this._listNote[index].title,
                style: titleStyle,
              ),
              subtitle: Text(this._listNote[index].description),
              trailing: GestureDetector(
                child: Icon(
                  Icons.delete,
                ),
                onTap: () {
                  deleteIcon(context, this._listNote[index]);
                },
              ),
              onTap: () {
                navigateToDetail(this._listNote[index], 'Edit Note');
              },
            ),
          );
        });
  }

  ///return the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
    }
  }

  ///return the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void deleteIcon(BuildContext context, NoteModel noteModel) async {
    int result = await _databaseHelper.deleteNote(noteModel.id);
    if (result == 0) {
      _showSnackbar(context, "Note Deleted Successfully");
      updateListView();
    }
  }

  void _showSnackbar(BuildContext context, String msg) {
    final snackbar = SnackBar(
      content: Text(msg),
    );
    Scaffold.of(context).showSnackBar(snackbar);
  }

  navigateToDetail(NoteModel note, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = _databaseHelper.initializeDatabase();
    dbFuture.then((database) {

      Future<List<NoteModel>> noteListFuture = _databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this._listNote = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
