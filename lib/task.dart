import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'helpers/cloud_firestore_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<FormState> insertFormKey = GlobalKey();
  GlobalKey<FormState> updateFormKey = GlobalKey();

  TextEditingController titleController = TextEditingController();
  TextEditingController updatedTitleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController updateDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController updatedDescriptionController = TextEditingController();

  String? title;
  String? date;
  String? description;
  String? updatedTitle;
  String? updateDate;
  String? updatedDescription;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Note-Keeper"),
        centerTitle: true,
        leading: const Icon(
          Icons.label_important,
          color: Colors.white,
          size: 30,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addRecords,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: CloudFirestoreHelper.cloudFirestoreHelper.selectRecord(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: SelectableText("${snapshot.error}"),
              );
            } else if (snapshot.hasData) {
              QuerySnapshot? data = snapshot.data;
              List<QueryDocumentSnapshot> documents = data!.docs;
              return (documents.isNotEmpty)
                  ? ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, i) {
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const StretchMotion(),
                      children: [
                        SlidableAction(
                          flex: 2,
                          onPressed: (context) async {
                            updateRecord(
                              id: documents[i].id,
                              title: documents[i]['title'],
                              date: documents[i]['date'],
                              description: documents[i]['description'],
                            );
                          },
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                        ),
                        SlidableAction(
                          flex: 2,
                          onPressed: (context) async {
                            await CloudFirestoreHelper
                                .cloudFirestoreHelper
                                .deleteRecord(
                              id: documents[i].id,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                Text("Successfully Task Deleted"),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                        ),
                      ],
                    ),
                    child: Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 6,
                      child: ListTile(
                        isThreeLine: true,
                        leading: Text("${i + 1}"),
                        title: Text(
                          "${documents[i]['title']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        subtitle: Text("${documents[i]['description']}"),
                        trailing: Text("${documents[i]['date']}"),
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.access_time_outlined,
                      size: 100,
                      color: Colors.teal,
                    ),
                    Text(
                      "No Task Yet !",
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.teal,
                ),
              );
            }
          }),
    );
  }

  void addRecords() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Note(Task)"),
          content: Form(
            key: insertFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Enter title",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.teal,
                      ),
                    ),
                    labelStyle: TextStyle(color: Colors.teal),
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                  controller: titleController,
                  onSaved: (val) {
                    setState(() {
                      title = val;
                    });
                  },
                  validator: (val) =>
                  (val!.isEmpty) ? "Enter your title first" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    hintText: "Enter date",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.teal,
                      ),
                    ),
                    labelStyle: TextStyle(color: Colors.teal),
                    labelText: "Date",
                  ),
                  controller: dateController,
                  onSaved: (val) {
                    setState(() {
                      date = val;
                    });
                  },
                  validator: (val) =>
                  (val!.isEmpty) ? "Enter your date first" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Enter description",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.teal,
                      ),
                    ),
                    labelStyle: TextStyle(color: Colors.teal),
                    labelText: "Description",
                  ),
                  controller: descriptionController,
                  onSaved: (val) {
                    setState(() {
                      description = val;
                    });
                  },
                  validator: (val) =>
                  (val!.isEmpty) ? "Enter your description first" : null,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (insertFormKey.currentState!.validate()) {
                  insertFormKey.currentState!.save();

                  // await CloudFirestoreHelper.cloudFirestoreHelper.insertRecord(
                  //     title: title!, description: description!, date: date!);

                  await CloudFirestoreHelper.cloudFirestoreHelper
                      .insertRecord(
                      title: title!, description: description!, date: date!, data: '')
                      .then((value) {
                    return ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Successfully Task Added"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.teal,
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
                titleController.clear();
                descriptionController.clear();
                dateController.clear();

                setState(() {
                  title = "";
                  description = "";
                  date = "";
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text("Add"),
            ),
            ElevatedButton(
              onPressed: () {
                titleController.clear();
                descriptionController.clear();
                dateController.clear();
                setState(() {
                  title = null;
                  description = null;
                  date = null;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void updateRecord({
    required String id,
    required String title,
    required String date,
    required String description,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        updatedTitleController.text = title;
        updateDateController.text = date;
        updatedDescriptionController.text = description;
        return AlertDialog(
          title: const Text("Update Note(Task)"),
          content: Form(
            key: updateFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Enter title",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.teal,
                      ),
                    ),
                    labelStyle: TextStyle(color: Colors.teal),
                    labelText: "Title",
                  ),
                  controller: updatedTitleController,
                  onSaved: (val) {
                    setState(() {
                      updatedTitle = val;
                    });
                  },
                  validator: (val) =>
                  (val!.isEmpty) ? "Enter your title first" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    hintText: "Enter date",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.teal,
                      ),
                    ),
                    labelStyle: TextStyle(color: Colors.teal),
                    labelText: "Date",
                  ),
                  controller: updateDateController,
                  onSaved: (val) {
                    setState(() {
                      updateDate = val!;
                    });
                  },
                  validator: (val) =>
                  (val!.isEmpty) ? "Enter your date first" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Enter description",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.teal,
                      ),
                    ),
                    labelStyle: TextStyle(color: Colors.teal),
                    labelText: "Description",
                  ),
                  controller: updatedDescriptionController,
                  onSaved: (val) {
                    setState(() {
                      updatedDescription = val;
                    });
                  },
                  validator: (val) =>
                  (val!.isEmpty) ? "Enter your description first" : null,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (updateFormKey.currentState!.validate()) {
                  updateFormKey.currentState!.save();

                  Map<String, dynamic> updatedData = {
                    'title': updatedTitle,
                    'date': updateDate,
                    'description': updatedDescription,
                  };
                  await CloudFirestoreHelper.cloudFirestoreHelper
                      .updateRecord(updateData: updatedData, updatedId: id, updateId: '', id: '', title: '', data: '');

                  updatedDescriptionController.clear();
                  updatedTitleController.clear();
                  updateDateController.clear();

                  setState(() {
                    updatedTitle = null;
                    updateDate = null;
                    updatedDescription = null;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Successfully Task Updated"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.teal,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text("Update"),
            ),
            ElevatedButton(
              onPressed: () {
                updatedDescriptionController.clear();
                updatedTitleController.clear();
                updateDateController.clear();
                setState(() {
                  updatedTitle = null;
                  updateDate = null;
                  updatedDescription = null;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
