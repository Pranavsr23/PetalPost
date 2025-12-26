import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:firebase_core/firebase_core.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:home_widget/home_widget.dart";

import "app.dart";
import "core/config/app_config.dart";
import "core/services/analytics_service.dart";
import "providers/service_providers.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  if (AppConfig.appGroupId.isNotEmpty) {
    await HomeWidget.setAppGroupId(AppConfig.appGroupId);
  }
  final analytics = await AnalyticsService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        analyticsServiceProvider.overrideWithValue(analytics),
      ],
      child: const PetalPostApp(),
    ),
  );
}
