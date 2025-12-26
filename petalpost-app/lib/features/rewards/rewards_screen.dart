import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../core/theme/app_colors.dart";
import "../../data/models/reward_badge.dart";
import "../../providers/data_providers.dart";
import "../../shared/widgets/empty_state.dart";
import "../home/widgets/home_bottom_nav.dart";
import "../notes/compose_note_screen.dart";

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  static const String routePath = "/rewards";

  List<RewardBadge> _badges() {
    return const [
      RewardBadge(id: "first_note", title: "First Note", description: "Send your first note.", pointsRequired: 20),
      RewardBadge(id: "streak_3", title: "3-Day Streak", description: "Share notes 3 days in a row.", pointsRequired: 60),
      RewardBadge(id: "lover", title: "Love Keeper", description: "Favorite 10 notes.", pointsRequired: 250),
      RewardBadge(id: "milestone", title: "Milestone", description: "Celebrate 100 love points.", pointsRequired: 100),
    ];
  }

  List<_RewardShopItem> _shopItems() {
    return const [
      _RewardShopItem(
        title: "Pastel Theme",
        subtitle: "App Color Scheme",
        points: "500",
        accent: Color(0xFFFFE1EA),
      ),
      _RewardShopItem(
        title: "Cute Stickers",
        subtitle: "Pack of 20",
        points: "300",
        accent: Color(0xFFFFF2D9),
      ),
      _RewardShopItem(
        title: "Cursive Font",
        subtitle: "Typography Style",
        points: "Purchased",
        accent: Color(0xFFE7F0FF),
        purchased: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
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
        activeIndex: 2,
        onHome: () => context.go("/home"),
        onMemories: () => context.go("/memories"),
        onRewards: () {},
        onSettings: () => context.go("/settings"),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.blushBackground),
        child: SafeArea(
          child: profileAsync.when(
            data: (profile) {
              if (profile == null) {
                return const EmptyState(title: "No profile", subtitle: "Complete setup first.");
              }
              final points = profile.points;
              final streak = profile.streakCount;
              final unlocked = profile.badges.toSet();
              final badgeList = _badges();
              final shopItems = _shopItems();
              final nextBadge = badgeList.where((b) => b.pointsRequired > points).fold<RewardBadge?>(
                    null,
                    (current, badge) => current == null || badge.pointsRequired < current.pointsRequired
                        ? badge
                        : current,
                  );
              final progress = nextBadge == null
                  ? 1.0
                  : min(points / nextBadge.pointsRequired, 1.0);

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.ink,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Rewards",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.history),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: "Love points",
                          value: points.toString(),
                          icon: Icons.favorite,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: "Day streak",
                          value: streak.toString(),
                          icon: Icons.local_fire_department,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text("Next unlock", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.softStroke),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextBadge?.title ?? "All rewards unlocked",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          nextBadge?.description ?? "You have every badge.",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.softStroke,
                            color: AppColors.primary,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nextBadge == null
                              ? "Complete"
                              : "$points / ${nextBadge.pointsRequired} pts",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text("Badges", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                      children: badgeList
                          .map(
                            (badge) => _BadgeTile(
                              badge: badge,
                              isUnlocked: unlocked.contains(badge.id),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 24),
                  Text("Spend points", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 190,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final item = shopItems[index];
                        return _RewardShopCard(item: item);
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: shopItems.length,
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const EmptyState(
              title: "Couldn't load rewards",
              subtitle: "Try again later.",
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softStroke),
      ),
      child: Column(
        children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(color: color)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.isUnlocked});

  final RewardBadge badge;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? AppColors.primary : AppColors.softStroke,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnlocked ? Icons.verified : Icons.lock,
            color: isUnlocked ? AppColors.primary : AppColors.mutedText,
          ),
          const SizedBox(height: 6),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _RewardShopItem {
  const _RewardShopItem({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.accent,
    this.purchased = false,
  });

  final String title;
  final String subtitle;
  final String points;
  final Color accent;
  final bool purchased;
}

class _RewardShopCard extends StatelessWidget {
  const _RewardShopCard({required this.item});

  final _RewardShopItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softStroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: item.accent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(item.subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.mutedText)),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: item.purchased
                        ? AppColors.softStroke
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.points,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: item.purchased
                                  ? AppColors.mutedText
                                  : AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (!item.purchased) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.favorite,
                            size: 14, color: AppColors.primary),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
