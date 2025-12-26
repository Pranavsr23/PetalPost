import "package:flutter_riverpod/flutter_riverpod.dart";
import "../data/models/note.dart";
import "../data/models/space.dart";
import "../data/models/user_profile.dart";
import "../providers/app_state_providers.dart";
import "../providers/repository_providers.dart";

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(userRepositoryProvider).watchProfile(user.uid);
});

final spacesProvider = StreamProvider<List<Space>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }
  return ref.watch(spaceRepositoryProvider).watchSpaces(user.uid);
});

final selectedSpaceIdProvider = Provider<String?>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  final spacesAsync = ref.watch(spacesProvider);
  if (profileAsync is AsyncData && spacesAsync is AsyncData) {
    final settingsId = profileAsync.value?.settings.widgetSpaceId;
    final spaces = spacesAsync.value ?? [];
    if (settingsId != null && spaces.any((space) => space.id == settingsId)) {
      return settingsId;
    }
    return spaces.isNotEmpty ? spaces.first.id : null;
  }
  return null;
});

final selectedSpaceProvider = Provider<Space?>((ref) {
  final spacesAsync = ref.watch(spacesProvider);
  final selectedId = ref.watch(selectedSpaceIdProvider);
  if (spacesAsync is AsyncData) {
    final spaces = spacesAsync.value ?? const <Space>[];
    if (spaces.isEmpty) {
      return null;
    }
    if (selectedId == null) {
      return spaces.first;
    }
    return spaces.firstWhere(
      (space) => space.id == selectedId,
      orElse: () => spaces.first,
    );
  }
  return null;
});

final notesProvider = StreamProvider.family<List<Note>, String>((ref, spaceId) {
  return ref.watch(noteRepositoryProvider).watchNotes(spaceId);
});

final latestNoteProvider = StreamProvider.family<Note?, String>((ref, spaceId) {
  return ref.watch(noteRepositoryProvider).watchLatest(spaceId);
});

final favoriteNotesProvider = StreamProvider.family<List<Note>, String>((ref, spaceId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }
  return ref.watch(noteRepositoryProvider).watchFavorites(spaceId, user.uid);
});
