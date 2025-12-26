import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";

import "../../core/theme/app_colors.dart";
import "../../data/models/user_settings.dart";
import "../../providers/app_state_providers.dart";
import "../../providers/data_providers.dart";
import "../../providers/repository_providers.dart";
import "../../providers/service_providers.dart";
import "invite_partner_screen.dart";

class JoinSpaceScreen extends ConsumerStatefulWidget {
  const JoinSpaceScreen({super.key});

  static const String routePath = "/spaces/join";

  @override
  ConsumerState<JoinSpaceScreen> createState() => _JoinSpaceScreenState();
}

class _JoinSpaceScreenState extends ConsumerState<JoinSpaceScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isJoining = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isJoining = true;
      _error = null;
    });

    final code = _codeController.text.trim().toUpperCase();
    final space = await ref
        .read(spaceRepositoryProvider)
        .joinSpace(uid: user.uid, inviteCode: code);
    if (space == null) {
      setState(() {
        _isJoining = false;
        _error = "Invite code not found";
      });
      return;
    }

    final settings = (ref.read(userProfileProvider).valueOrNull?.settings ??
            const UserSettings())
        .copyWith(widgetSpaceId: space.id);
    await ref.read(userRepositoryProvider).updateSettings(user.uid, settings);
    await ref.read(widgetServiceProvider).saveWidgetMode(
          spaceId: space.id,
          mode: settings.widgetMode,
          blurMode: settings.blurMode,
          anniversaryDate: space.anniversaryDate,
        );
    await ref.read(widgetServiceProvider).requestWidgetUpdate();

    if (mounted) {
      setState(() => _isJoining = false);
      context.go(InvitePartnerScreen.routePath);
    }
  }

  Future<void> _pasteCode() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    setState(() {
      _codeController.text = text.toUpperCase();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.ink,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Join Space",
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Connect with\nyour partner",
                          style: theme.textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter the invite code your partner shared with you to start sending PetalPosts.",
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.12),
                                AppColors.primary.withValues(alpha: 0.2),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.favorite,
                                        color: AppColors.primary, size: 36),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                    const Icon(Icons.phonelink_ring,
                                        color: AppColors.primary, size: 36),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Invite Code",
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            TextField(
                              controller: _codeController,
                              textCapitalization: TextCapitalization.characters,
                              style: theme.textTheme.titleMedium?.copyWith(
                                letterSpacing: 2,
                              ),
                              decoration: InputDecoration(
                                hintText: "XR7-9K2",
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(20, 18, 96, 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color:
                                        AppColors.primary.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color:
                                        AppColors.primary.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              top: 10,
                              bottom: 10,
                              child: TextButton.icon(
                                onPressed: _pasteCode,
                                icon: const Icon(Icons.content_paste, size: 16),
                                label: const Text("Paste"),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  foregroundColor: AppColors.primary,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.error,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                _error!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isJoining ? null : _join,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            child: _isJoining
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text("Connecting..."),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text("Join Space"),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: AppColors.softStroke),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "OR",
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: AppColors.mutedText),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: AppColors.softStroke),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text("Scan QR Code"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.ink,
                              side: BorderSide(color: AppColors.softStroke),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ),
                      ],
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
}
