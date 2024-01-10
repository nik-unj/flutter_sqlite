import 'package:flutter/material.dart';
import 'package:flutter_sqlite/model/note_model.dart';
import 'package:flutter_sqlite/service/sqlite_service.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class HomeController extends GetxController {
  RxList<Note> notes = <Note>[].obs;
  RxBool isedit = false.obs;
  TextEditingController idController = TextEditingController();
  TextEditingController descController = TextEditingController();
  final SqliteService _sqliteService = SqliteService();

  void initalize() {
    _sqliteService.initializeDB().whenComplete(() async {
      refreshNotes();
    });
  }

  void refreshNotes() async {
    final data = await _sqliteService.getItems();
    notes.value = data;
  }

  void addNote(Function callback) {
    if (idController.text.isNotEmpty && descController.text.isNotEmpty) {
      _sqliteService.createItem(Note(
          id: int.parse(idController.text), description: descController.text));
      callback("Note Added");
      idController.clear();
      descController.clear();
    } else {
      callback("Please fill all the fields", success: false);
    }
    refreshNotes();
  }

  void editNote(int noteId) async {
    Note note = notes.firstWhere((element) => element.id == noteId);
    idController.text = note.id.toString();
    descController.text = note.description;
    isedit.value = true;
  }

  void deleteNote(int noteId, Function callback) async {
    await _sqliteService.deleteItem(noteId.toString());
    callback("Note $noteId Deleted", success: false);
    refreshNotes();
  }

  void updateNote(int noteId, Function callback) async {
    if (idController.text.isNotEmpty && descController.text.isNotEmpty) {
      await _sqliteService.update(
        Note(
          id: int.parse(idController.text),
          description: descController.text,
        ),
      );
      callback("Note $noteId Updated");
      idController.clear();
      descController.clear();
      isedit.value = false;
    } else {
      callback("Please fill all the fields", success: false);
    }

    refreshNotes();
  }
}
