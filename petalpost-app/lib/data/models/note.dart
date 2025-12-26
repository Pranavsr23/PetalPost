import "package:cloud_firestore/cloud_firestore.dart";
import "note_type.dart";

class Note {
  const Note({
    required this.id,
    required this.senderUid,
    required this.createdAt,
    required this.type,
    this.text,
    this.imageUrl,
    this.thumbnailUrl,
    this.audioUrl,
    this.audioDurationSec,
    this.waveformPeaks,
    required this.surprise,
    required this.timeCapsule,
    this.unlockAt,
    required this.deliveredTo,
    required this.readBy,
    required this.reactions,
    required this.isFavoriteBy,
  });

  final String id;
  final String senderUid;
  final DateTime createdAt;
  final NoteType type;
  final String? text;
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? audioUrl;
  final int? audioDurationSec;
  final List<int>? waveformPeaks;
  final bool surprise;
  final bool timeCapsule;
  final DateTime? unlockAt;
  final Map<String, DateTime> deliveredTo;
  final Map<String, DateTime> readBy;
  final Map<String, String> reactions;
  final Map<String, bool> isFavoriteBy;

  bool get isLocked {
    if (!timeCapsule || unlockAt == null) {
      return false;
    }
    return unlockAt!.isAfter(DateTime.now());
  }

  factory Note.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Note(
      id: doc.id,
      senderUid: data["senderUid"] as String? ?? "",
      createdAt: _readTimestamp(data["createdAt"]) ?? DateTime.now(),
      type: noteTypeFromString(data["type"] as String? ?? "text"),
      text: data["text"] as String?,
      imageUrl: data["imageUrl"] as String?,
      thumbnailUrl: data["thumbnailUrl"] as String?,
      audioUrl: data["audioUrl"] as String?,
      audioDurationSec: data["audioDurationSec"] as int?,
      waveformPeaks: _readPeaks(data["waveformPeaks"]),
      surprise: data["surprise"] as bool? ?? false,
      timeCapsule: data["timeCapsule"] as bool? ?? false,
      unlockAt: _readTimestamp(data["unlockAt"]),
      deliveredTo: _readDateMap(data["deliveredTo"]),
      readBy: _readDateMap(data["readBy"]),
      reactions: Map<String, String>.from(data["reactions"] as Map? ?? {}),
      isFavoriteBy: Map<String, bool>.from(data["isFavoriteBy"] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "senderUid": senderUid,
      "createdAt": Timestamp.fromDate(createdAt),
      "type": noteTypeToString(type),
      "text": text,
      "imageUrl": imageUrl,
      "thumbnailUrl": thumbnailUrl,
      "audioUrl": audioUrl,
      "audioDurationSec": audioDurationSec,
      "waveformPeaks": waveformPeaks,
      "surprise": surprise,
      "timeCapsule": timeCapsule,
      "unlockAt": unlockAt == null ? null : Timestamp.fromDate(unlockAt!),
      "deliveredTo": _writeDateMap(deliveredTo),
      "readBy": _writeDateMap(readBy),
      "reactions": reactions,
      "isFavoriteBy": isFavoriteBy,
    }..removeWhere((key, value) => value == null);
  }

  static DateTime? _readTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  static Map<String, DateTime> _readDateMap(dynamic value) {
    if (value is Map) {
      return value.map((key, val) {
        return MapEntry(key.toString(), _readTimestamp(val) ?? DateTime.now());
      });
    }
    return {};
  }

  static Map<String, dynamic> _writeDateMap(Map<String, DateTime> value) {
    return value.map((key, val) => MapEntry(key, Timestamp.fromDate(val)));
  }

  static List<int>? _readPeaks(dynamic value) {
    if (value is List) {
      return value.map((entry) => entry is int ? entry : (entry as num).toInt()).toList();
    }
    return null;
  }
}
