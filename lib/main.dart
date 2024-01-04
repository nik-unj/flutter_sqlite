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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
  void _refreshNotes() async {
    final data = await _sqliteService.getItems();
    setState(() {
      _notes = data;
    });
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
                    if (id.text.isNotEmpty && desc.text.isNotEmpty) {
                      _sqliteService.createItem(
                          Note(id: int.parse(id.text), description: desc.text));
                    }
                    _refreshNotes();
                    id.clear();
                    desc.clear();
                  },
                  child: const Text("Add"),
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
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await _sqliteService
                                      .deleteItem(_notes[index].id.toString());
                                  _refreshNotes();
                                },
                              ),
                              title: Text(_notes[index].id.toString()),
                              subtitle: Text(_notes[index].description),
                            );
                          }),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
