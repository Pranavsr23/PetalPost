class UserSettings {
  const UserSettings({
    this.widgetSpaceId,
    this.widgetMode = "latest",
    this.blurMode = true,
  });

  final String? widgetSpaceId;
  final String widgetMode;
  final bool blurMode;

  factory UserSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const UserSettings();
    }
    return UserSettings(
      widgetSpaceId: map["widgetSpaceId"] as String?,
      widgetMode: map["widgetMode"] as String? ?? "latest",
      blurMode: map["blurMode"] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "widgetSpaceId": widgetSpaceId,
      "widgetMode": widgetMode,
      "blurMode": blurMode,
    }..removeWhere((key, value) => value == null);
  }

  UserSettings copyWith({
    String? widgetSpaceId,
    String? widgetMode,
    bool? blurMode,
  }) {
    return UserSettings(
      widgetSpaceId: widgetSpaceId ?? this.widgetSpaceId,
      widgetMode: widgetMode ?? this.widgetMode,
      blurMode: blurMode ?? this.blurMode,
    );
  }
}
