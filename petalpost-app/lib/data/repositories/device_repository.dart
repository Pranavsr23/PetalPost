import "package:cloud_firestore/cloud_firestore.dart";
import "../models/device_info.dart";

class DeviceRepository {
  DeviceRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> upsertDevice(String uid, DeviceInfo device) async {
    await _firestore
        .collection("users")
        .doc(uid)
        .collection("devices")
        .doc(device.deviceId)
        .set(device.toMap(), SetOptions(merge: true));
  }
}
