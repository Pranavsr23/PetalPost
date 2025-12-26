import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../core/theme/app_colors.dart";
import "../../data/models/user_settings.dart";
import "../../providers/app_state_providers.dart";
import "../../providers/data_providers.dart";
import "../../providers/repository_providers.dart";
import "../../providers/service_providers.dart";
import "../../shared/utils/date_formatters.dart";
import "invite_partner_screen.dart";

class CreateSpaceScreen extends ConsumerStatefulWidget {
  const CreateSpaceScreen({super.key});

  static const String routePath = "/spaces/create";

  @override
  ConsumerState<CreateSpaceScreen> createState() => _CreateSpaceScreenState();
}

class _CreateSpaceScreenState extends ConsumerState<CreateSpaceScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _anniversary;
  bool _isSaving = false;
  int _themeIndex = 0;

  final List<_ThemeOption> _themes = const [
    _ThemeOption(
      id: "sweet",
      label: "Sweet",
      colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
    ),
    _ThemeOption(
      id: "dreamy",
      label: "Dreamy",
      colors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
    ),
    _ThemeOption(
      id: "fresh",
      label: "Fresh",
      colors: [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() => _anniversary = selected);
    }
  }

  Future<void> _create() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);
    final themeId = _themes[_themeIndex].id;
    final space = await ref.read(spaceRepositoryProvider).createSpace(
          name: name,
          createdBy: user.uid,
          themeId: themeId,
          anniversaryDate: _anniversary,
        );

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
      setState(() => _isSaving = false);
      context.go(InvitePartnerScreen.routePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 40,
              right: -60,
              child: _DecorBlob(
                color: AppColors.primary.withValues(alpha: 0.08),
                size: 180,
              ),
            ),
            Positioned(
              bottom: 60,
              left: -60,
              child: _DecorBlob(
                color: const Color(0xFFBFA4FF).withValues(alpha: 0.08),
                size: 140,
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
                      const Spacer(),
                      Text(
                        "Create Space",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name your space",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Us",
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: const Icon(Icons.edit, color: AppColors.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: const BorderSide(color: AppColors.softStroke),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: const BorderSide(color: AppColors.softStroke),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Pick a theme",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_themes.length, (index) {
                            final themeOption = _themes[index];
                            final isSelected = _themeIndex == index;
                            return GestureDetector(
                              onTap: () => setState(() => _themeIndex = index),
                              child: Column(
                                children: [
                                  AnimatedScale(
                                    scale: isSelected ? 1.08 : 1,
                                    duration: const Duration(milliseconds: 200),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(colors: themeOption.colors),
                                        border: Border.all(
                                          color: isSelected ? AppColors.primary : Colors.transparent,
                                          width: 2,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primary.withValues(alpha: 0.2),
                                                  blurRadius: 12,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    themeOption.label,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: isSelected ? AppColors.primary : AppColors.mutedText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Text(
                              "Anniversary",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "(Optional)",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.mutedText,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.softStroke),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _anniversary == null
                                        ? "Select date"
                                        : DateFormatters.formatMonthDay(_anniversary!),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                const Icon(Icons.calendar_today, size: 18, color: AppColors.mutedText),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "This powers your anniversary countdown widget.",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.mutedText),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _create,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 6,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Create Space"),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption {
  const _ThemeOption(
      {required this.id, required this.label, required this.colors});

  final String id;
  final String label;
  final List<Color> colors;
}

class _DecorBlob extends StatelessWidget {
  const _DecorBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
