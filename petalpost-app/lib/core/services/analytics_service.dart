import "package:mixpanel_flutter/mixpanel_flutter.dart";
import "../config/app_config.dart";

class AnalyticsService {
  AnalyticsService(this._mixpanel);

  final Mixpanel? _mixpanel;

  static Future<AnalyticsService> initialize() async {
    if (AppConfig.mixpanelToken.isEmpty) {
      return AnalyticsService(null);
    }
    final mixpanel = await Mixpanel.init(
      AppConfig.mixpanelToken,
      trackAutomaticEvents: true,
    );
    return AnalyticsService(mixpanel);
  }

  void identify(String userId) {
    _mixpanel?.identify(userId);
  }

  void registerSuperProperties(Map<String, Object?> props) {
    _mixpanel?.registerSuperProperties(props);
  }

  void track(String event, {Map<String, Object?> properties = const {}}) {
    _mixpanel?.track(event, properties: properties);
  }

  void setUserProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) {
    _mixpanel?.getPeople().set("uid", userId);
    if (displayName != null) {
      _mixpanel?.getPeople().set("displayName", displayName);
    }
    if (avatarUrl != null) {
      _mixpanel?.getPeople().set("avatarUrl", avatarUrl);
    }
  }
}
