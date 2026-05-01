import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dream_model.dart';

class DreamStorageService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static Future<List<Dream>> loadDreams() async {
    if (_uid == null) return [];
    try {
      final snapshot = await _db
          .collection('users')
          .doc(_uid)
          .collection('dreams')
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Dream.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> addDream(Dream dream) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('dreams')
        .doc(dream.id)
        .set(dream.toJson());
  }

  static Future<void> updateDream(Dream dream) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('dreams')
        .doc(dream.id)
        .update(dream.toJson());
  }

  static Future<void> deleteDream(String id) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('dreams')
        .doc(id)
        .delete();
  }
}
