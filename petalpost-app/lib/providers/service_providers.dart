import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core/services/analytics_service.dart";
import "../core/services/notification_service.dart";
import "../core/services/onboarding_service.dart";
import "../core/services/permissions_service.dart";
import "../core/services/time_service.dart";
import "../core/services/widget_service.dart";
import "../core/services/device_id_service.dart";

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  throw UnimplementedError("AnalyticsService not initialized");
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(firebaseMessagingProvider));
});

final permissionsServiceProvider = Provider<PermissionsService>((ref) {
  return PermissionsService();
});

final timeServiceProvider = Provider<TimeService>((ref) {
  return TimeService();
});

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

final deviceIdServiceProvider = Provider<DeviceIdService>((ref) {
  return DeviceIdService();
});

final widgetServiceProvider = Provider<WidgetService>((ref) {
  return WidgetService();
});
