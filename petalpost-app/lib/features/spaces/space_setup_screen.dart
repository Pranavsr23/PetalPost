import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";

import "../../core/theme/app_colors.dart";
import "create_space_screen.dart";
import "join_space_screen.dart";

class SpaceSetupScreen extends StatelessWidget {
  const SpaceSetupScreen({super.key});

  static const String routePath = "/spaces/setup";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Theme(
          data: theme.copyWith(
            textTheme: GoogleFonts.manropeTextTheme(theme.textTheme),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
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
                          child: Center(
                            child: Text(
                              "Space Setup",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            "Your Spaces",
                            style: Theme.of(context).textTheme.displaySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Create one for each relationship or memory lane.",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: const Color(0xFF9A4C5F)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          _SpaceActionCard(
                            icon: Icons.favorite,
                            title: "Create a Space",
                            subtitle: "Start a new journey with your partner.",
                            onTap: () => context.go(CreateSpaceScreen.routePath),
                          ),
                          const SizedBox(height: 16),
                          _SpaceActionCard(
                            icon: Icons.vpn_key,
                            title: "Join with Code",
                            subtitle: "Enter a code shared by your partner.",
                            onTap: () => context.go(JoinSpaceScreen.routePath),
                          ),
                          const Spacer(),
                          Text(
                            "You can switch Spaces anytime",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.mutedText,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpaceActionCard extends StatelessWidget {
  const _SpaceActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
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
            Icon(Icons.chevron_right, color: AppColors.primary.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
