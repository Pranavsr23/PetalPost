import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    required this.onHome,
    required this.onMemories,
    required this.onRewards,
    required this.onSettings,
    this.activeIndex = 0,
    this.hasFab = true,
  });

  final VoidCallback onHome;
  final VoidCallback onMemories;
  final VoidCallback onRewards;
  final VoidCallback onSettings;
  final int activeIndex;
  final bool hasFab;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: const Border(top: BorderSide(color: AppColors.softStroke)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: Icons.home,
            label: "Home",
            isActive: activeIndex == 0,
            onTap: onHome,
          ),
          _NavItem(
            icon: Icons.favorite,
            label: "Memories",
            isActive: activeIndex == 1,
            onTap: onMemories,
          ),
          if (hasFab) const SizedBox(width: 56),
          _NavItem(
            icon: Icons.local_activity,
            label: "Rewards",
            isActive: activeIndex == 2,
            onTap: onRewards,
          ),
          _NavItem(
            icon: Icons.settings,
            label: "Settings",
            isActive: activeIndex == 3,
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.mutedText;
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
