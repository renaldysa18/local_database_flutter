import 'package:local_database_flutter/src/model/note_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';


  ///name constructor
  DatabaseHelper._createInstance();

  ///singleton
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }

    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }

    return _database;
  }

  Future<Database> initializeDatabase() async {
    ///get directory path for android and ios to store database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    ///open / create the db at a given path
    var noteDatabase = await openDatabase(path, version: 1, onCreate: _createDatabase);
    return noteDatabase;
  }

  ///create db
  _createDatabase(Database db, int version) async {
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  ///fetch all from db
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

//    var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  ///insert to db
  Future<int> insertNote(NoteModel noteModel) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, noteModel.toMap());
    return result;
  }

  ///update to db
  Future<int> updateNote(NoteModel noteModel) async {
    Database db = await this.database;
    var result = await db.update(noteTable, noteModel.toMap(), where: '$colId = ?', whereArgs: [noteModel.id]);
    return result;
  }
  ///delete to db
  Future<int> deleteNote(int id) async {
    Database db = await this.database;
    int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  ///get number of note object in db
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  ///get the 'map list' and conver to note model
  Future<List<NoteModel>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<NoteModel> notelist = List<NoteModel>();

    for(int i = 0; i< count; i++){
      notelist.add(NoteModel.fromMapObject(noteMapList[i]));
    }

    return notelist;
  }
}
