import "package:home_widget/home_widget.dart";

class WidgetKeys {
  static const String spaceId = "widget_space_id";
  static const String mode = "widget_mode";
  static const String blurMode = "widget_blur_mode";
  static const String latestNotePreview = "latest_note_preview";
  static const String latestNoteSender = "latest_note_sender";
  static const String latestNoteAt = "latest_note_at";
  static const String latestNoteLockedUntil = "latest_note_locked_until";
  static const String hasUnread = "latest_note_unread";
  static const String anniversaryDate = "anniversary_date";
  static const String daysTogether = "anniversary_days";
  static const String nextMilestone = "anniversary_next_milestone";
}

class WidgetService {
  Future<void> saveLatestNote({
    required String preview,
    required String senderName,
    required DateTime createdAt,
    bool hasUnread = true,
    DateTime? lockedUntil,
  }) async {
    await HomeWidget.saveWidgetData(WidgetKeys.latestNotePreview, preview);
    await HomeWidget.saveWidgetData(WidgetKeys.latestNoteSender, senderName);
    await HomeWidget.saveWidgetData(WidgetKeys.latestNoteAt, createdAt.toIso8601String());
    await HomeWidget.saveWidgetData(WidgetKeys.latestNoteLockedUntil, lockedUntil?.toIso8601String());
    await HomeWidget.saveWidgetData(WidgetKeys.hasUnread, hasUnread);
  }

  Future<void> saveWidgetMode({
    required String spaceId,
    required String mode,
    required bool blurMode,
    DateTime? anniversaryDate,
  }) async {
    await HomeWidget.saveWidgetData(WidgetKeys.spaceId, spaceId);
    await HomeWidget.saveWidgetData(WidgetKeys.mode, mode);
    await HomeWidget.saveWidgetData(WidgetKeys.blurMode, blurMode);
    await HomeWidget.saveWidgetData(WidgetKeys.anniversaryDate, anniversaryDate?.toIso8601String());
  }

  Future<void> saveAnniversaryMetrics({
    required int daysTogether,
    required int nextMilestone,
  }) async {
    await HomeWidget.saveWidgetData(WidgetKeys.daysTogether, daysTogether);
    await HomeWidget.saveWidgetData(WidgetKeys.nextMilestone, nextMilestone);
  }

  Future<void> requestWidgetUpdate() async {
    await HomeWidget.updateWidget(
      name: "PetalPostWidgetProvider",
      iOSName: "PetalPostWidget",
      androidName: "PetalPostWidgetProvider",
    );
  }
}
