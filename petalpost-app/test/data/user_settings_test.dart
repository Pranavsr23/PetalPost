import "package:flutter_test/flutter_test.dart";
import "package:petalpost/data/models/user_settings.dart";

void main() {
  test("UserSettings defaults are applied", () {
    final settings = UserSettings.fromMap(null);
    expect(settings.widgetMode, "latest");
    expect(settings.blurMode, true);
  });

  test("UserSettings maps to map correctly", () {
    const settings = UserSettings(widgetSpaceId: "space", widgetMode: "anniversary", blurMode: false);
    final map = settings.toMap();
    expect(map["widgetSpaceId"], "space");
    expect(map["widgetMode"], "anniversary");
    expect(map["blurMode"], false);
  });
}
