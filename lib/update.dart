import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notekeeper_app_master/helpers/cloud_firestore_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> insertFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> updateFormKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String? title;
  String? note;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("Keep Notes"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: CloudFirestoreHelper.cloudFirestoreHelper.selectRecord(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            QuerySnapshot? data = snapshot.data;

            List<QueryDocumentSnapshot> documents = data!.docs;

            return (documents.isEmpty)
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Spacer(),
                  Icon(
                    Icons.note_add_outlined,
                    size: 70,
                    color: Colors.amber,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Notes you add appear here",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  Spacer(),
                ],
              ),
            )
                : Container(
              margin: const EdgeInsets.all(5),
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: documents.length,
                  itemBuilder: (context, i) {
                    return Card(
                      elevation: 10,
                      child: ListTile(
                        isThreeLine: true,
                        // leading: Text("${i + 1}"),
                        // leading: Text("${documents[i].id}"),
                        title: Text("${documents[i]['title']}"),
                        subtitle: Text("${documents[i]['data']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                validateAndUpdate(
                                    updata: documents[i].id);
                                titleController.text =
                                documents[i]['title'];

                                noteController.text =
                                documents[i]['data'];
                              },
                              icon: const Icon(
                                Icons.edit_note_outlined,
                                color: Colors.blue,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                CloudFirestoreHelper.cloudFirestoreHelper
                                    .deleteRecord(id: documents[i].id);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            validateAndInsert();
          },
          label: const Text("ADD"),
          backgroundColor: Colors.amber,
          icon: const Icon(Icons.note_alt_outlined)),
    );
  }

  //for insert record===========================
  void validateAndInsert() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            elevation: 10,
            title: const Center(child: Text("New Note")),
            content: Form(
              key: insertFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: titleController,
                        validator: (val) {
                          return (val!.isEmpty) ? "Enter title first" : null;
                        },
                        onSaved: (val) {
                          setState(() {
                            title = val;
                          });
                        },
                        decoration: InputDecoration(
                            label: const Text("Title"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: noteController,
                        validator: (val) {
                          return (val!.isEmpty) ? "Enter note first" : null;
                        },
                        onSaved: (val) {
                          setState(() {
                            note = val;
                          });
                        },
                        decoration: InputDecoration(
                            label: const Text("Note"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (insertFormKey.currentState!.validate()) {
                    insertFormKey.currentState!.save();

                    await CloudFirestoreHelper.cloudFirestoreHelper
                        .insertRecord(
                      date: '',
                      description: '',
                      title: title!,
                      data: note!,
                    )
                        .then((value) {
                      return ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          content: Text("note added successfully..."),
                        ),
                      );
                    }).catchError(
                          (error) {
                        return ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $error"),
                          ),
                        );
                      },
                    );
                  }
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //     content: Text("Record Inserted successfully..."),
                  //   ),
                  // );
                  titleController.clear();
                  noteController.clear();

                  setState(() {
                    title = null;
                    note = null;
                  });

                  Navigator.of(context).pop();
                },
                child: const Text("ADD"),
              ),
              ElevatedButton(
                onPressed: () async {
                  titleController.clear();
                  noteController.clear();
                  setState(() {
                    title = null;
                    note = null;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              )
            ],
          );
        });
  }

  //for update record===========================
  void validateAndUpdate({required updata}) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            clipBehavior: Clip.none,
            title: const Center(child: Text("Edit Note")),
            content: Form(
              key: updateFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: titleController,
                        validator: (val) {
                          return (val!.isEmpty) ? "Enter title first" : null;
                        },
                        onSaved: (val) {
                          setState(() {
                            title = val;
                          });
                        },
                        decoration: InputDecoration(
                            label: const Text("Title"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: noteController,
                        validator: (val) {
                          return (val!.isEmpty) ? "Enter note first" : null;
                        },
                        onSaved: (val) {
                          setState(() {
                            note = val;
                          });
                        },
                        decoration: InputDecoration(
                            label: const Text("Note"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (updateFormKey.currentState!.validate()) {
                    updateFormKey.currentState!.save();

                    await CloudFirestoreHelper.cloudFirestoreHelper
                        .updateRecord(
                      updatedId: '',
                      id: updata,
                      title: title!,
                      data: note!, updateData: {}, updateId: '',
                    )
                        .then((value) {
                      return ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          content: Text("Note Edited successfully..."),
                        ),
                      );
                    }).catchError(
                          (error) {
                        return ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Note edition filed...Error: $error"),
                          ),
                        );
                      },
                    );
                  }

                  titleController.clear();
                  noteController.clear();
                  setState(() {
                    title = "";
                    note = "";
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("Edit"),
              ),
              ElevatedButton(
                onPressed: () async {
                  titleController.clear();
                  noteController.clear();
                  setState(() {
                    title = null;
                    note = null;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              )
            ],
          );
        });
  }
}
