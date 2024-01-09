import 'package:flutter/material.dart';
import 'package:flutter_sqlite/model/note_model.dart';
import 'package:flutter_sqlite/service/sqlite_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController id = TextEditingController();
  TextEditingController desc = TextEditingController();
  List<Note> _notes = [];
  late SqliteService _sqliteService;
  bool _isediting = false;
  void _refreshNotes() async {
    final data = await _sqliteService.getItems();
    setState(() {
      _notes = data;
    });
  }

  void alert(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
      duration: const Duration(seconds: 1),
    ));
  }

  void addNote() {
    if (id.text.isNotEmpty && desc.text.isNotEmpty) {
      _sqliteService
          .createItem(Note(id: int.parse(id.text), description: desc.text));
      alert("Note Added");
      id.clear();
      desc.clear();
    } else {
      alert("Please fill all the fields", success: false);
    }
    _refreshNotes();
  }

  void editNote(int noteId) async {
    Note note = _notes.firstWhere((element) => element.id == noteId);
    setState(() {
      id.text = note.id.toString();
      desc.text = note.description;
      _isediting = true;
    });
  }

  void updateNote(int noteId) async {
    if (id.text.isNotEmpty && desc.text.isNotEmpty) {
      await _sqliteService.update(
        Note(
          id: int.parse(id.text),
          description: desc.text,
        ),
      );
      alert("Note $noteId Updated");
      id.clear();
      desc.clear();
      setState(() {
        _isediting = false;
      });
    } else {
      alert("Please fill all the fields", success: false);
    }

    _refreshNotes();
  }

  void deleteNote(int noteId) async {
    await _sqliteService.deleteItem(noteId.toString());
    alert("Note $noteId Deleted", success: false);
    _refreshNotes();
  }

  @override
  void initState() {
    super.initState();
    _sqliteService = SqliteService();
    _sqliteService.initializeDB().whenComplete(() async {
      _refreshNotes();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "Sqlite",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: id,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    labelText: 'Id',
                    hintText: '123',
                  ),
                  keyboardType: TextInputType.number,
                  readOnly: _isediting,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: desc,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    labelText: 'Description',
                    hintText: 'Write message',
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_isediting) {
                      final int noteId = int.parse(id.text);
                      updateNote(noteId);
                    } else {
                      addNote();
                    }
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: Text(_isediting ? "Update" : "Add"),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "List of notes",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _notes.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Text(
                          "No records found",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      editNote(_notes[index].id);
                                    },
                                  ),
                                  IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () =>
                                          deleteNote(_notes[index].id))
                                ],
                              ),
                            ),
                            title: Text(_notes[index].id.toString()),
                            subtitle: Text(_notes[index].description),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
