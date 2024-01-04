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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                  controller: id,
                  decoration: const InputDecoration(
                    labelText: 'Id',
                  ),
                  keyboardType: TextInputType.number),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: desc,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
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
            Expanded(
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
            )
          ],
        ),
      ),
    );
  }
}
