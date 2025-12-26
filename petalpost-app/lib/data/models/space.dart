import "package:cloud_firestore/cloud_firestore.dart";

class Space {
  const Space({
    required this.id,
    required this.name,
    required this.themeId,
    required this.createdAt,
    required this.createdBy,
    required this.participantUids,
    this.anniversaryDate,
    this.lastNoteId,
    this.lastNotePreview,
    this.lastNoteAt,
    required this.inviteCode,
  });

  final String id;
  final String name;
  final String themeId;
  final DateTime createdAt;
  final String createdBy;
  final List<String> participantUids;
  final DateTime? anniversaryDate;
  final String? lastNoteId;
  final String? lastNotePreview;
  final DateTime? lastNoteAt;
  final String inviteCode;

  factory Space.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Space(
      id: doc.id,
      name: data["name"] as String? ?? "",
      themeId: data["themeId"] as String? ?? "default",
      createdAt: _readTimestamp(data["createdAt"]) ?? DateTime.now(),
      createdBy: data["createdBy"] as String? ?? "",
      participantUids: List<String>.from(data["participantUids"] as List? ?? []),
      anniversaryDate: _readTimestamp(data["anniversaryDate"]),
      lastNoteId: data["lastNoteId"] as String?,
      lastNotePreview: data["lastNotePreview"] as String?,
      lastNoteAt: _readTimestamp(data["lastNoteAt"]),
      inviteCode: data["inviteCode"] as String? ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "themeId": themeId,
      "createdAt": Timestamp.fromDate(createdAt),
      "createdBy": createdBy,
      "participantUids": participantUids,
      "anniversaryDate": anniversaryDate == null ? null : Timestamp.fromDate(anniversaryDate!),
      "lastNoteId": lastNoteId,
      "lastNotePreview": lastNotePreview,
      "lastNoteAt": lastNoteAt == null ? null : Timestamp.fromDate(lastNoteAt!),
      "inviteCode": inviteCode,
    }..removeWhere((key, value) => value == null);
  }

  static DateTime? _readTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}
