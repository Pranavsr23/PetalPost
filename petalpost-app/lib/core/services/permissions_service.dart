import "package:permission_handler/permission_handler.dart";

class PermissionsService {
  Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
}
