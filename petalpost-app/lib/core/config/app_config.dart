class AppConfig {
  static const String environment = String.fromEnvironment("APP_ENV", defaultValue: "dev");
  static const String mixpanelToken = String.fromEnvironment("MIXPANEL_TOKEN", defaultValue: "");
  static const String firebaseProjectId = String.fromEnvironment("FIREBASE_PROJECT_ID", defaultValue: "");
  static const String appGroupId = String.fromEnvironment("APP_GROUP_ID", defaultValue: "");

  static bool get isProd => environment == "prod";
}
