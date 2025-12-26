import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../core/theme/app_colors.dart";
import "../../data/models/device_info.dart";
import "../../data/models/note.dart";
import "../../data/models/user_settings.dart";
import "../../providers/app_state_providers.dart";
import "../../providers/data_providers.dart";
import "../../providers/repository_providers.dart";
import "../../providers/service_providers.dart";
import "../../shared/utils/date_formatters.dart";
import "../../shared/widgets/empty_state.dart";
import "../../shared/widgets/loading_state.dart";
import "../notes/compose_note_screen.dart";
import "../reveal/reveal_screen.dart";
import "../rewards/rewards_screen.dart";
import "../settings/settings_screen.dart";
import "../love_jar/memories_screen.dart";
import "../spaces/space_setup_screen.dart";
import "widgets/hero_note_card.dart";
import "widgets/home_bottom_nav.dart";
import "widgets/home_header.dart";
import "widgets/note_timeline_item.dart";

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const String routePath = "/home";

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _deviceRegistered = false;
  StreamSubscription<String>? _tokenSubscription;

  @override
  void initState() {
    super.initState();
    _registerDevice();
  }

  @override
  void dispose() {
    _tokenSubscription?.cancel();
    super.dispose();
  }

  Future<void> _registerDevice() async {
    if (_deviceRegistered) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize();
    final token = await notificationService.getToken();
    if (token == null) return;
    final deviceId = await ref.read(deviceIdServiceProvider).getDeviceId();
    final platform = Platform.isIOS ? "ios" : "android";
    final deviceInfo = DeviceInfo(
      deviceId: deviceId,
      fcmToken: token,
      platform: platform,
      updatedAt: DateTime.now(),
    );
    await ref.read(deviceRepositoryProvider).upsertDevice(user.uid, deviceInfo);
    _tokenSubscription ??=
        notificationService.onTokenRefresh.listen((token) async {
      final refreshedDevice = DeviceInfo(
        deviceId: deviceId,
        fcmToken: token,
        platform: platform,
        updatedAt: DateTime.now(),
      );
      await ref
          .read(deviceRepositoryProvider)
          .upsertDevice(user.uid, refreshedDevice);
    });
    _deviceRegistered = true;
  }

  void _syncWidgetSettings() {
    final space = ref.read(selectedSpaceProvider);
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (space == null || profile == null) return;
    final settings = profile.settings;
    ref.read(widgetServiceProvider).saveWidgetMode(
          spaceId: space.id,
          mode: settings.widgetMode,
          blurMode: settings.blurMode,
          anniversaryDate: space.anniversaryDate,
        );
    if (space.anniversaryDate != null) {
      final daysTogether =
          DateFormatters.daysTogether(space.anniversaryDate!, DateTime.now());
      final nextMilestone = DateFormatters.nextMilestoneDays(
          space.anniversaryDate!, DateTime.now());
      ref.read(widgetServiceProvider).saveAnniversaryMetrics(
            daysTogether: daysTogether,
            nextMilestone: nextMilestone,
          );
    }
  }

  void _syncLatestNote(Note note, String senderName) {
    ref.read(widgetServiceProvider).saveLatestNote(
          preview: note.text ?? "New note",
          senderName: senderName,
          createdAt: note.createdAt,
          hasUnread: true,
          lockedUntil: note.unlockAt,
        );
    ref.read(widgetServiceProvider).requestWidgetUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final spacesAsync = ref.watch(spacesProvider);
    final space = ref.watch(selectedSpaceProvider);

    ref.listen(selectedSpaceProvider, (prev, next) {
      if (next != null) {
        _syncWidgetSettings();
        ref.read(widgetServiceProvider).requestWidgetUpdate();
      }
    });

    if (space != null) {
      ref.listen<AsyncValue<Note?>>(
        latestNoteProvider(space.id),
        (previous, next) {
          final profile = ref.read(userProfileProvider).valueOrNull;
          final senderName = profile?.displayName ?? "Partner";
          final note = next.valueOrNull;
          if (note != null) {
            _syncLatestNote(note, senderName);
          }
        },
      );
    }

    if (profileAsync.isLoading || spacesAsync.isLoading) {
      return const LoadingState();
    }

    if (space == null) {
      return Scaffold(
        body: Container(
          decoration:
              const BoxDecoration(gradient: AppGradients.blushBackground),
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: EmptyState(
                title: "Create your first space",
                subtitle: "Start a shared space for notes and memories.",
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.go(SpaceSetupScreen.routePath),
          backgroundColor: AppColors.primary,
          elevation: 8,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 28),
        ),
      );
    }

    final notesAsync = ref.watch(notesProvider(space.id));
    final user = ref.watch(currentUserProvider);
    final points = profileAsync.valueOrNull?.points ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(ComposeNoteScreen.routePath),
        backgroundColor: AppColors.primary,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: HomeBottomNav(
        activeIndex: 0,
        onHome: () {},
        onMemories: () => context.go(MemoriesScreen.routePath),
        onRewards: () => context.go(RewardsScreen.routePath),
        onSettings: () => context.go(SettingsScreen.routePath),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.blushBackground),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                HomeHeader(
                  space: space,
                  points: points,
                  onSpaceTap: () => _showSpaceSheet(context),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: notesAsync.when(
                    data: (notes) {
                      final theme = Theme.of(context);
                      if (notes.isEmpty) {
                        return ListView(
                          padding: const EdgeInsets.only(bottom: 140),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.mail_outline,
                                      size: 40, color: AppColors.primary),
                                  const SizedBox(height: 12),
                                  Text(
                                    "No notes yet",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Send something sweet to get started.",
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      final latestUnread = _latestUnread(notes, user?.uid);
                      final heroNote = latestUnread;
                      final remaining = heroNote == null
                          ? notes
                          : notes
                              .where((note) => note.id != heroNote.id)
                              .toList();
                      final todayNotes = remaining
                          .where((note) => _isToday(note.createdAt))
                          .toList();
                      final earlierNotes = remaining
                          .where((note) => !_isToday(note.createdAt))
                          .toList();
                      final heroSender = heroNote == null
                          ? null
                          : _senderLabel(heroNote, user?.uid);
                      final heroTime = heroNote == null
                          ? null
                          : DateFormatters.formatTime(heroNote.createdAt);

                      return ListView(
                        padding: const EdgeInsets.only(bottom: 140),
                        children: [
                          if (heroNote != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Latest from ${heroSender ?? "Your partner"}",
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(heroTime ?? "",
                                    style: theme.textTheme.bodySmall),
                              ],
                            ),
                            const SizedBox(height: 12),
                            HeroNoteCard(
                              note: heroNote,
                              senderName: heroSender ?? "Your partner",
                              onTap: () => context.go(
                                RevealScreen.routePath,
                                extra: heroNote,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.mail_outline,
                                      size: 40, color: AppColors.primary),
                                  const SizedBox(height: 12),
                                  Text(
                                    "No unread notes",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Send something sweet to get started.",
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          if (todayNotes.isNotEmpty) ...[
                            Text("Today", style: theme.textTheme.titleMedium),
                            const SizedBox(height: 12),
                            ...todayNotes.map(
                              (note) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: NoteTimelineItem(
                                  note: note,
                                  isUnread: user == null
                                      ? false
                                      : !note.readBy.containsKey(user.uid) &&
                                          note.senderUid != user.uid,
                                  onTap: () => context.go(
                                    RevealScreen.routePath,
                                    extra: note,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (earlierNotes.isNotEmpty) ...[
                            Text("Earlier", style: theme.textTheme.titleMedium),
                            const SizedBox(height: 12),
                            ...earlierNotes.map(
                              (note) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: NoteTimelineItem(
                                  note: note,
                                  isUnread: user == null
                                      ? false
                                      : !note.readBy.containsKey(user.uid) &&
                                          note.senderUid != user.uid,
                                  onTap: () => context.go(
                                    RevealScreen.routePath,
                                    extra: note,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () => const LoadingState(),
                    error: (_, __) => const EmptyState(
                      title: "Could not load notes",
                      subtitle: "Check your connection and try again.",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Note? _latestUnread(List<Note> notes, String? uid) {
    if (uid == null) return null;
    for (final note in notes) {
      if (note.senderUid != uid && !note.readBy.containsKey(uid)) {
        return note;
      }
    }
    return null;
  }

  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  String _senderLabel(Note note, String? uid) {
    if (uid != null && note.senderUid == uid) {
      return "You";
    }
    return "Your partner";
  }

  Future<void> _showSpaceSheet(BuildContext context) async {
    final spaces = ref.read(spacesProvider).valueOrNull ?? [];
    final currentSpaceId = ref.read(selectedSpaceIdProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Choose space",
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...spaces.map(
                (space) => ListTile(
                  title: Text(space.name),
                  trailing: currentSpaceId == space.id
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    final user = ref.read(currentUserProvider);
                    if (user == null) return;
                    final profile = ref.read(userProfileProvider).valueOrNull;
                    final settings = (profile?.settings ?? const UserSettings())
                        .copyWith(widgetSpaceId: space.id);
                    await ref
                        .read(userRepositoryProvider)
                        .updateSettings(user.uid, settings);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => context.go(SpaceSetupScreen.routePath),
                icon: const Icon(Icons.add),
                label: const Text("Create or join another space"),
              ),
            ],
          ),
        );
      },
    );
  }
}
