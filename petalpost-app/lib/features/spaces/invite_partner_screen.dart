import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_fonts/google_fonts.dart";

import "../../core/theme/app_colors.dart";
import "../../providers/data_providers.dart";

class InvitePartnerScreen extends ConsumerStatefulWidget {
  const InvitePartnerScreen({super.key});

  static const String routePath = "/spaces/invite";

  @override
  ConsumerState<InvitePartnerScreen> createState() =>
      _InvitePartnerScreenState();
}

class _InvitePartnerScreenState extends ConsumerState<InvitePartnerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotsController;
  late final List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _dotAnimations = [
      _buildDotAnimation(0.0, 0.6),
      _buildDotAnimation(0.2, 0.8),
      _buildDotAnimation(0.4, 1.0),
    ];
  }

  Animation<double> _buildDotAnimation(double start, double end) {
    return Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _dotsController,
        curve: Interval(start, end, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invite code copied")),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final space = ref.watch(selectedSpaceProvider);
    final inviteCode = space?.inviteCode ?? "----";
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.blushBackground),
        child: SafeArea(
          child: Theme(
            data: theme.copyWith(
              textTheme: GoogleFonts.manropeTextTheme(theme.textTheme),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.ink,
                        ),
                      ),
                      const Spacer(),
                      Text("Invite Partner", style: theme.textTheme.titleMedium),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: [
                        Text(
                          "Invite your partner",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "They will join your space and start receiving notes immediately.",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: space == null
                              ? null
                              : () => _copyCode(inviteCode),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.softStroke),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withOpacity(0.12),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    inviteCode,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: AppColors.primary,
                                      letterSpacing: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.copy,
                                    color: AppColors.mutedText),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tap code to copy",
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          height: 220,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: AppColors.softStroke),
                          ),
                          child: const Center(
                            child: Icon(Icons.qr_code,
                                size: 120, color: AppColors.mutedText),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _showMessage("Share link copied"),
                                icon: const Icon(Icons.ios_share),
                                label: const Text("Share"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.ink,
                                  side: const BorderSide(
                                      color: AppColors.softStroke),
                                  shape: const StadiumBorder(),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _showMessage("Invite sent to your partner"),
                                icon: const Icon(Icons.send),
                                label: const Text("Send Invite"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
                    border: const Border(
                        top: BorderSide(color: AppColors.softStroke)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.backgroundLight,
                        child: Icon(Icons.person, color: AppColors.mutedText),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Waiting for partner",
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(
                                _dotAnimations.length,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: FadeTransition(
                                    opacity: _dotAnimations[index],
                                    child: const _Dot(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite,
                            color: AppColors.mutedText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}
