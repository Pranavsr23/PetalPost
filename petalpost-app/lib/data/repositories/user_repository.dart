import "package:cloud_firestore/cloud_firestore.dart";
import "../models/user_profile.dart";
import "../models/user_settings.dart";

class UserRepository {
  UserRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection("users").doc(uid);
  }

  Stream<UserProfile?> watchProfile(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.id, doc.data() ?? {});
    });
  }

  Future<UserProfile?> fetchProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.id, doc.data() ?? {});
  }

  Future<void> upsertProfile(UserProfile profile) async {
    await _userDoc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
  }

  Future<void> updateSettings(String uid, UserSettings settings) async {
    await _userDoc(uid).set({"settings": settings.toMap()}, SetOptions(merge: true));
  }

  Future<void> updateAvatar(String uid, String? avatarUrl) async {
    await _userDoc(uid).set({"avatarUrl": avatarUrl}, SetOptions(merge: true));
  }

  Future<void> updateDisplayName(String uid, String displayName) async {
    await _userDoc(uid).set({"displayName": displayName}, SetOptions(merge: true));
  }

  Future<void> updatePoints(String uid, int points) async {
    await _userDoc(uid).set({"points": points}, SetOptions(merge: true));
  }

  Future<void> updateBadges(String uid, List<String> badges) async {
    await _userDoc(uid).set({"badges": badges}, SetOptions(merge: true));
  }
}
