import "dart:io";
import "package:firebase_storage/firebase_storage.dart";

class StorageRepository {
  StorageRepository(this._storage);

  final FirebaseStorage _storage;

  Future<String> uploadHandwriting({
    required String spaceId,
    required String noteId,
    required File file,
  }) async {
    final ref = _storage.ref("spaces/$spaceId/notes/$noteId/handwriting.png");
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<String> uploadVoice({
    required String spaceId,
    required String noteId,
    required File file,
  }) async {
    final ref = _storage.ref("spaces/$spaceId/notes/$noteId/voice.m4a");
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
