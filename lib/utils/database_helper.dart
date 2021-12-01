import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:project_1/models/note.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; //Singleton DatabaseHelper
  static Database _database;
  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance(); //named constructor to create instance of DatabaseHelper

//factory constructor
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); //this is executed only once,singleton object

    }
    return _databaseHelper;
  }

//create getter for our database
  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  //function to initialize our database
  Future<Database> initializeDatabase() async {
    //get the directory path for both android and ios to store database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    //open/create  the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

//now create database
  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle TEXT,$colDescription TEXT ,$colPriority INTEGER,$colDate TEXT)');
  }

// fetch operation: get all notes from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    // var result =await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');//these is the rawQuery
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

// Insert operation: insert a note object to database

  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

//update operation:update a note Object and save it to the database
  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId= ?', whereArgs: [note.id]);
    return result;
  }

//Delete operation:delete a note object from database
  Future<int> deleteNote(int id) async {
    var db = await this.database;
    var result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId=$id');
    return result;
  }

  //Get number of Note Objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //get the 'Map List'  [List<Map>] and convert it to the 'Note List' [List<Note>]
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList(); //get ' Map List ' from database
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();
    //for loop to create a 'NoteList' from a 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}
