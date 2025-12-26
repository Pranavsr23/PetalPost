import "package:cloud_firestore/cloud_firestore.dart";

class DeviceInfo {
  const DeviceInfo({
    required this.deviceId,
    required this.fcmToken,
    required this.platform,
    required this.updatedAt,
  });

  final String deviceId;
  final String fcmToken;
  final String platform;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      "fcmToken": fcmToken,
      "platform": platform,
      "updatedAt": Timestamp.fromDate(updatedAt),
    };
  }
}
