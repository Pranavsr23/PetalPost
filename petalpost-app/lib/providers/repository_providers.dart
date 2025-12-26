import "package:flutter_riverpod/flutter_riverpod.dart";
import "../data/repositories/auth_repository.dart";
import "../data/repositories/device_repository.dart";
import "../data/repositories/note_repository.dart";
import "../data/repositories/space_repository.dart";
import "../data/repositories/storage_repository.dart";
import "../data/repositories/user_repository.dart";
import "service_providers.dart";

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(firestoreProvider));
});

final spaceRepositoryProvider = Provider<SpaceRepository>((ref) {
  return SpaceRepository(ref.watch(firestoreProvider));
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(ref.watch(firestoreProvider));
});

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(ref.watch(firebaseStorageProvider));
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepository(ref.watch(firestoreProvider));
});
