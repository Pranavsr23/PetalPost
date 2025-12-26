import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../core/theme/app_colors.dart";
import "../../data/models/user_profile.dart";
import "../../data/models/user_settings.dart";
import "../../features/home/home_screen.dart";
import "../../providers/app_state_providers.dart";
import "../../providers/repository_providers.dart";
import "../../providers/service_providers.dart";
import "../../shared/widgets/primary_button.dart";

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  static const String routePath = "/profile-setup";

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final displayName = _nameController.text.trim();
    if (displayName.isEmpty) {
      return;
    }

    setState(() => _isSaving = true);
    final profile = UserProfile(
      uid: user.uid,
      displayName: displayName,
      nickname: _nicknameController.text.trim().isEmpty
          ? null
          : _nicknameController.text.trim(),
      avatarUrl: user.photoURL,
      createdAt: DateTime.now(),
      settings: const UserSettings(),
    );

    await ref.read(userRepositoryProvider).upsertProfile(profile);
    ref.read(analyticsServiceProvider).identify(user.uid);
    ref.read(analyticsServiceProvider).setUserProfile(
          userId: user.uid,
          displayName: displayName,
          avatarUrl: user.photoURL,
        );

    if (mounted) {
      setState(() => _isSaving = false);
      context.go(HomeScreen.routePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.blushBackground),
        child: SafeArea(
          child: Column(
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
                      child: Text(
                        "Profile Setup",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ProgressDot(isActive: true, width: 28),
                    const SizedBox(width: 6),
                    _ProgressDot(isActive: false),
                    const SizedBox(width: 6),
                    _ProgressDot(isActive: false),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Who is this?",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Add a photo and name so your partner recognizes you instantly.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.mutedText),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 64,
                              backgroundColor: Colors.white,
                              child: const Icon(Icons.add_a_photo,
                                  color: AppColors.mutedText, size: 36),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.edit,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nameController,
                        decoration:
                            const InputDecoration(hintText: "Your name"),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.favorite,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "We need this so your partner knows it's you.",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.mutedText),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nicknameController,
                        decoration:
                            const InputDecoration(hintText: "Nickname (optional)"),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Honey, Sweetheart, or just your name.",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.mutedText),
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        label: "Continue",
                        isLoading: _isSaving,
                        onPressed: _isSaving ? null : _saveProfile,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.isActive, this.width = 10});

  final bool isActive;
  final double width;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 6,
      width: width,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.softStroke,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
