import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFirestoreHelper {
  CloudFirestoreHelper._();

  static final CloudFirestoreHelper cloudFirestoreHelper = CloudFirestoreHelper._();

  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late CollectionReference notesRef;
  void connectWithNotesCollection() {
    notesRef = firebaseFirestore.collection('Note_Keeper');
  }

  Future<void> insertRecord({
   required String title,
    required String description, required String date, required String data,
 }) async {
    connectWithNotesCollection();
    Map<String, dynamic> data = {
      'title' : title,
      'description' : description,
    };
    await notesRef.add(data);
  }

  Stream <QuerySnapshot> selectRecord() {
    connectWithNotesCollection();
    return notesRef.snapshots();
  }

  Future<void> updateRecord({
    required Map<String, dynamic> updateData,
    required String updateId, required String updatedId, required id, required String title, required String data,
}) async {
    connectWithNotesCollection();
    await notesRef.doc(updateId).update(updateData);
  }

  Future<void> deleteRecord({required String id}) async {
    connectWithNotesCollection();
    await notesRef.doc(id).delete();
  }
}