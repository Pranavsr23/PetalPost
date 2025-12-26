import "package:shared_preferences/shared_preferences.dart";
import "package:uuid/uuid.dart";

class DeviceIdService {
  static const String _key = "device_id";
  static const Uuid _uuid = Uuid();

  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final id = _uuid.v4();
    await prefs.setString(_key, id);
    return id;
  }
}
