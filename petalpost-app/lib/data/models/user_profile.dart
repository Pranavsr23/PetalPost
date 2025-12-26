import "package:cloud_firestore/cloud_firestore.dart";
import "user_settings.dart";

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    this.nickname,
    this.avatarUrl,
    required this.createdAt,
    required this.settings,
    this.points = 0,
    this.badges = const [],
    this.streakCount = 0,
  });

  final String uid;
  final String displayName;
  final String? nickname;
  final String? avatarUrl;
  final DateTime createdAt;
  final UserSettings settings;
  final int points;
  final List<String> badges;
  final int streakCount;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      displayName: map["displayName"] as String? ?? "",
      nickname: map["nickname"] as String?,
      avatarUrl: map["avatarUrl"] as String?,
      createdAt: _readTimestamp(map["createdAt"]) ?? DateTime.now(),
      settings: UserSettings.fromMap(map["settings"] as Map<String, dynamic>?),
      points: (map["points"] as int?) ?? 0,
      badges: List<String>.from(map["badges"] as List? ?? []),
      streakCount: (map["streakCount"] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "displayName": displayName,
      "nickname": nickname,
      "avatarUrl": avatarUrl,
      "createdAt": Timestamp.fromDate(createdAt),
      "settings": settings.toMap(),
      "points": points,
      "badges": badges,
      "streakCount": streakCount,
    }..removeWhere((key, value) => value == null);
  }

  UserProfile copyWith({
    String? displayName,
    String? nickname,
    String? avatarUrl,
    UserSettings? settings,
    int? points,
    List<String>? badges,
    int? streakCount,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      settings: settings ?? this.settings,
      points: points ?? this.points,
      badges: badges ?? this.badges,
      streakCount: streakCount ?? this.streakCount,
    );
  }

  static DateTime? _readTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}
