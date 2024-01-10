import 'package:flutter/material.dart';
import 'package:flutter_sqlite/controller/home_controller.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

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
  final _homeController = Get.put(HomeController());

  void alert(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  void initState() {
    super.initState();
    _homeController.initalize();
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
              Obx(
                () => Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: _homeController.idController,
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
                    readOnly: _homeController.isedit.value,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _homeController.descController,
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
                child: Obx(
                  () => ElevatedButton(
                    onPressed: () {
                      if (_homeController.isedit.value) {
                        final int noteId =
                            int.parse(_homeController.idController.text);
                        _homeController.updateNote(noteId, alert);
                      } else {
                        _homeController.addNote(alert);
                      }
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child:
                        Text(_homeController.isedit.value ? "Update" : "Add"),
                  ),
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
              Obx(() {
                return _homeController.notes.isEmpty
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
                          itemCount: _homeController.notes.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              trailing: SizedBox(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        _homeController.editNote(
                                            _homeController.notes[index].id);
                                      },
                                    ),
                                    IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          _homeController.deleteNote(
                                            _homeController.notes[index].id,
                                            alert,
                                          );
                                        }),
                                  ],
                                ),
                              ),
                              title: Text(
                                  _homeController.notes[index].id.toString()),
                              subtitle: Text(
                                  _homeController.notes[index].description),
                            );
                          },
                        ),
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
