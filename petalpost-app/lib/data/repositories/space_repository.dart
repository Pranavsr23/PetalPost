import "package:cloud_firestore/cloud_firestore.dart";
import "package:uuid/uuid.dart";
import "../models/space.dart";

class SpaceRepository {
  SpaceRepository(this._firestore) : _uuid = const Uuid();

  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  CollectionReference<Map<String, dynamic>> get _spaces =>
      _firestore.collection("spaces");

  Stream<List<Space>> watchSpaces(String uid) {
    return _spaces.where("participantUids", arrayContains: uid).snapshots().map(
          (snapshot) => snapshot.docs.map(Space.fromDoc).toList(),
        );
  }

  Future<Space> createSpace({
    required String name,
    required String createdBy,
    required String themeId,
    DateTime? anniversaryDate,
  }) async {
    final doc = _spaces.doc();
    final space = Space(
      id: doc.id,
      name: name,
      themeId: themeId,
      createdAt: DateTime.now(),
      createdBy: createdBy,
      participantUids: [createdBy],
      anniversaryDate: anniversaryDate,
      lastNoteId: null,
      lastNotePreview: null,
      lastNoteAt: null,
      inviteCode: _generateInviteCode(),
    );
    await doc.set(space.toMap());
    return space;
  }

  Future<Space?> joinSpace({
    required String uid,
    required String inviteCode,
  }) async {
    final match =
        await _spaces.where("inviteCode", isEqualTo: inviteCode).limit(1).get();
    if (match.docs.isEmpty) {
      return null;
    }
    final doc = match.docs.first;
    final data = doc.data();
    final participants =
        List<String>.from(data["participantUids"] as List? ?? []);
    if (!participants.contains(uid)) {
      participants.add(uid);
      await doc.reference.update({"participantUids": participants});
    }
    return Space.fromDoc(doc);
  }

  Future<void> updateAnniversary(String spaceId, DateTime date) async {
    await _spaces
        .doc(spaceId)
        .update({"anniversaryDate": Timestamp.fromDate(date)});
  }

  Future<void> updateLastNote({
    required String spaceId,
    required String noteId,
    required String preview,
    required DateTime createdAt,
  }) async {
    await _spaces.doc(spaceId).update({
      "lastNoteId": noteId,
      "lastNotePreview": preview,
      "lastNoteAt": Timestamp.fromDate(createdAt),
    });
  }

  String _generateInviteCode() {
    final raw = _uuid.v4().replaceAll("-", "");
    return raw.substring(0, 8).toUpperCase();
  }
}
