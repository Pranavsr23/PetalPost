import "package:cloud_firestore/cloud_firestore.dart";
import "../models/note.dart";

class NoteRepository {
  NoteRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _notes(String spaceId) {
    return _firestore.collection("spaces").doc(spaceId).collection("notes");
  }

  DocumentReference<Map<String, dynamic>> newNoteRef(String spaceId) {
    return _notes(spaceId).doc();
  }

  Stream<List<Note>> watchNotes(String spaceId) {
    return _notes(spaceId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Note.fromDoc).toList());
  }

  Stream<Note?> watchLatest(String spaceId) {
    return _notes(spaceId)
        .orderBy("createdAt", descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty ? null : Note.fromDoc(snapshot.docs.first));
  }

  Stream<List<Note>> watchFavorites(String spaceId, String uid) {
    return _notes(spaceId)
        .where("isFavoriteBy.$uid", isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Note.fromDoc).toList());
  }

  Future<String> createNote(String spaceId, Note note) async {
    final doc = _notes(spaceId).doc();
    await doc.set(note.toMap());
    return doc.id;
  }

  Future<void> markRead({
    required String spaceId,
    required String noteId,
    required String uid,
  }) async {
    await _notes(spaceId).doc(noteId).update({
      "readBy.$uid": Timestamp.now(),
    });
  }

  Future<void> react({
    required String spaceId,
    required String noteId,
    required String uid,
    required String emoji,
  }) async {
    await _notes(spaceId).doc(noteId).update({
      "reactions.$uid": emoji,
    });
  }

  Future<void> toggleFavorite({
    required String spaceId,
    required String noteId,
    required String uid,
    required bool isFavorite,
  }) async {
    await _notes(spaceId).doc(noteId).update({
      "isFavoriteBy.$uid": isFavorite,
    });
  }
}
