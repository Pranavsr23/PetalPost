import "package:fake_cloud_firestore/fake_cloud_firestore.dart";
import "package:flutter_test/flutter_test.dart";

import "package:petalpost/data/models/note.dart";
import "package:petalpost/data/models/note_type.dart";

void main() {
  test("Note mapping preserves core fields", () async {
    final store = FakeFirebaseFirestore();
    final doc = store.collection("spaces").doc("space").collection("notes").doc("note");
    await doc.set({
      "senderUid": "userA",
      "createdAt": DateTime(2024, 1, 1),
      "type": "text",
      "text": "Hello",
      "surprise": true,
      "timeCapsule": false,
    });

    final snap = await doc.get();
    final note = Note.fromDoc(snap);

    expect(note.senderUid, "userA");
    expect(note.type, NoteType.text);
    expect(note.text, "Hello");
    expect(note.surprise, true);
    expect(note.timeCapsule, false);
  });
}
