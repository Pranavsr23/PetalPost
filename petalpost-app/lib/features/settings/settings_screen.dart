import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../core/theme/app_colors.dart";
import "../../data/models/user_settings.dart";
import "../../data/models/space.dart";
import "../../providers/app_state_providers.dart";
import "../../providers/data_providers.dart";
import "../../providers/repository_providers.dart";
import "../../providers/service_providers.dart";
import "../../shared/utils/date_formatters.dart";
import "../../shared/widgets/empty_state.dart";
import "../home/widgets/home_bottom_nav.dart";
import "../notes/compose_note_screen.dart";

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static const String routePath = "/settings";

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _privacyLock = false;

  Future<void> _updateSettings({
    required WidgetRef ref,
    required UserSettings settings,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await ref.read(userRepositoryProvider).updateSettings(user.uid, settings);
    final space = ref.read(selectedSpaceProvider);
    await ref.read(widgetServiceProvider).saveWidgetMode(
          spaceId: settings.widgetSpaceId ?? space?.id ?? "",
          mode: settings.widgetMode,
          blurMode: settings.blurMode,
          anniversaryDate: space?.anniversaryDate,
        );
    if (space?.anniversaryDate != null) {
      final daysTogether =
          DateFormatters.daysTogether(space!.anniversaryDate!, DateTime.now());
      final nextMilestone =
          DateFormatters.nextMilestoneDays(space.anniversaryDate!, DateTime.now());
      await ref.read(widgetServiceProvider).saveAnniversaryMetrics(
            daysTogether: daysTogether,
            nextMilestone: nextMilestone,
          );
    }
    await ref.read(widgetServiceProvider).requestWidgetUpdate();
  }

  Future<void> _pickWidgetMode(
    BuildContext context,
    UserSettings settings,
  ) async {
    final mode = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text("Latest Note"),
                subtitle: const Text("Show the most recent love note"),
                onTap: () => Navigator.of(context).pop("latest"),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text("Anniversary"),
                subtitle: const Text("Show days together and milestones"),
                onTap: () => Navigator.of(context).pop("anniversary"),
              ),
            ],
          ),
        );
      },
    );
    if (mode == null) return;
    if (mode == settings.widgetMode) return;
    await _updateSettings(ref: ref, settings: settings.copyWith(widgetMode: mode));
  }

  Future<void> _pickWidgetSpace(
    BuildContext context,
    UserSettings settings,
    List<Space> spaces,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final space in spaces)
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: Text(space.name),
                  onTap: () => Navigator.of(context).pop(space.id),
                ),
            ],
          ),
        );
      },
    );
    if (selected == null || selected == settings.widgetSpaceId) return;
    await _updateSettings(ref: ref, settings: settings.copyWith(widgetSpaceId: selected));
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final spacesAsync = ref.watch(spacesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () => context.go(ComposeNoteScreen.routePath),
          backgroundColor: AppColors.primary,
          elevation: 8,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: HomeBottomNav(
        activeIndex: 3,
        onHome: () => context.go("/home"),
        onMemories: () => context.go("/memories"),
        onRewards: () => context.go("/rewards"),
        onSettings: () {},
      ),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return const EmptyState(
                title: "No profile",
                subtitle: "Complete setup first.",
              );
            }
            final settings = profile.settings;
            final spaces = spacesAsync.valueOrNull ?? [];
            final activeSpaceName = spaces.isEmpty
                ? "Our Love"
                : spaces
                    .firstWhere(
                      (space) => space.id == settings.widgetSpaceId,
                      orElse: () => spaces.first,
                    )
                    .name;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    Expanded(
                      child: Text(
                        "Settings",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "Widget Configuration",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mutedText,
                      ),
                ),
                const SizedBox(height: 12),
                const _WidgetPreviewCard(),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.favorite,
                        iconColor: AppColors.primary,
                        title: "Default Space",
                        trailing: activeSpaceName,
                        onTap: () => _pickWidgetSpace(context, settings, spaces),
                      ),
                      _SettingsRow(
                        icon: Icons.layers,
                        iconColor: const Color(0xFFF2A65B),
                        title: "Widget Mode",
                        trailing: settings.widgetMode == "anniversary"
                            ? "Anniversary"
                            : "Latest Note",
                        onTap: () => _pickWidgetMode(context, settings),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F0FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.blur_on,
                                      color: Color(0xFF4C7CF4), size: 18),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Blur Content",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F0F2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _SegmentButton(
                                      label: "Always",
                                      isActive: settings.blurMode,
                                      onTap: () => _updateSettings(
                                        ref: ref,
                                        settings:
                                            settings.copyWith(blurMode: true),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: _SegmentButton(
                                      label: "New Only",
                                      isActive: false,
                                      onTap: null,
                                    ),
                                  ),
                                  Expanded(
                                    child: _SegmentButton(
                                      label: "Never",
                                      isActive: !settings.blurMode,
                                      onTap: () => _updateSettings(
                                        ref: ref,
                                        settings:
                                            settings.copyWith(blurMode: false),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Controls when widget content is blurred for privacy.",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.mutedText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "General",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mutedText,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.notifications,
                        iconColor: AppColors.primary,
                        title: "Notifications",
                        onTap: () {},
                      ),
                      _SettingsToggleRow(
                        icon: Icons.lock,
                        iconColor: const Color(0xFF45B07C),
                        title: "Privacy Lock",
                        subtitle: "Use Face ID",
                        value: _privacyLock,
                        onChanged: (value) =>
                            setState(() => _privacyLock = value),
                      ),
                      _SettingsRow(
                        icon: Icons.diversity_1,
                        iconColor: const Color(0xFF7F6CF7),
                        title: "Manage Spaces",
                        trailing: "${spaces.length} Active",
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Support",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mutedText,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.help,
                        iconColor: const Color(0xFF9AA4AE),
                        title: "Help & Support",
                        onTap: () {},
                      ),
                      _SettingsRow(
                        icon: Icons.star,
                        iconColor: const Color(0xFFF2C14E),
                        title: "Rate PetalPost",
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                        ),
                        child: const Text("Delete Account"),
                      ),
                      Text(
                        "Version 2.4.0 (Build 184)",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.mutedText),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const EmptyState(
            title: "Couldn't load settings",
            subtitle: "Try again later.",
          ),
        ),
      ),
    );
  }
}

class _WidgetPreviewCard extends StatelessWidget {
  const _WidgetPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFECE9FF), Color(0xFFF6E9F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, color: AppColors.primary),
                    SizedBox(height: 6),
                    Text(
                      "Love Note",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        "Can't wait to see you",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: AppColors.mutedText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Widget Preview",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  "Live",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "See how your love notes appear on the home screen.",
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF2E7EA)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.mutedText),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(Icons.chevron_right, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF2E7EA)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isActive ? AppColors.primary : AppColors.mutedText,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
