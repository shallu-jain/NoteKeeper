import 'dart:ffi';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:project_1/models/note.dart';
import 'package:project_1/utils/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/src/material/theme_data.dart';


class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];
  String appBarTitle;
  Note note;

  DatabaseHelper helper = DatabaseHelper();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  NoteDetailState(this.note, this.appBarTitle);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline6;
    titleController.text = note.title;
    descriptionController.text = note.description;
    return WillPopScope(
        onWillPop: () {
          // Write some code to control things, when user press Back navigation button in device navigationBar

          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                moveToLastScreen();
              }
            ),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children:<Widget> [
                //first element is dropdown button
                ListTile(
                  title: DropdownButton(
                    items: _priorities.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    style: textStyle,
                    value: getPriorityAsString(note.priority),
                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        debugPrint('User Selected $valueSelectedByUser');
                        updatePriorityAsInt(valueSelectedByUser);
                      });
                    }
                  ),
                ),

                //second element that is text field for  Description

                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint("Something changed in description");
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                //third  element that is TextField  for title

                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint("Something changed in title");
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                //four element is row which is for the SAVE & DELETE button
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'SAVE',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint("Save Button Clicked");
                            _save();
                          });
                        },
                      )),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                          child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'DELETE',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint("Delete Button Clicked");
                            _delete();
                          });
                        },
                      ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context,true);
  }

  //convert the string priority in the form of integer before saving it to database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

//convert int priority to string priority and display it to user in dropdown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; //HIGH
        break;
      case 2:
        priority = _priorities[1]; //LOW
        break;
    }
    return priority;
  }

  //update the title of Note Object
  void updateTitle() {
    note.title = titleController.text;
  }

//  //update the description of Note Object
  void updateDescription() {
    note.description = descriptionController.text;
  }

//function to save data to database
  void _save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      //case 1:update the operation
      result = await helper.updateNote(note);
    } else {
      //case 2:insert operation
      result = await helper.insertNote(note);
    }
    if (result != 0) {
      //Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      //failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async{
    moveToLastScreen();
    //case 1:if user is trying to delete the NEW NOTE i.e. he has
    //to come to the detail page by pressing the FAB of NoteList  page.
    if (note.id==null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

        //case 2: user is trying to delete the old note that already has a valid ID.
    int result=await helper.deleteNote(note.id);
    if (result != 0) {
      //Success
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      //failure
      _showAlertDialog('Status', 'Error Occurred while deleting Note');
    }
  }


  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
