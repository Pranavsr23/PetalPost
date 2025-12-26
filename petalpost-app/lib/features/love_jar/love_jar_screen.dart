import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../core/theme/app_colors.dart";
import "../../data/models/note.dart";
import "../../providers/data_providers.dart";
import "../../shared/widgets/empty_state.dart";
import "../reveal/reveal_screen.dart";

class LoveJarScreen extends ConsumerStatefulWidget {
  const LoveJarScreen({super.key});

  static const String routePath = "/love-jar";

  @override
  ConsumerState<LoveJarScreen> createState() => _LoveJarScreenState();
}

class _LoveJarScreenState extends ConsumerState<LoveJarScreen> {
  Note? _selected;

  void _openJar(List<Note> favorites) {
    if (favorites.isEmpty) return;
    final random = Random();
    setState(() => _selected = favorites[random.nextInt(favorites.length)]);
  }

  @override
  Widget build(BuildContext context) {
    final space = ref.watch(selectedSpaceProvider);
    if (space == null) {
      return const Scaffold(
        body: Center(
            child: EmptyState(
                title: "No space", subtitle: "Create a space first.")),
      );
    }

    final favoritesAsync = ref.watch(favoriteNotesProvider(space.id));

    return Scaffold(
      backgroundColor: Colors.transparent,
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
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.ink,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: favoritesAsync.when(
                  data: (favorites) {
                    if (favorites.isEmpty) {
                      return const EmptyState(
                        title: "No favorites yet",
                        subtitle:
                            "Tap the heart on a note to add it to your jar.",
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      children: [
                        Text(
                          "Love Jar",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "A random favorite, whenever you need it.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 24),
                        _JarCard(onTap: () => _openJar(favorites)),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => _openJar(favorites),
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text("Open jar"),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 1,
                          color: AppColors.softStroke,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Favorites in jar",
                                style: Theme.of(context).textTheme.titleMedium),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                favorites.length.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (final note in favorites.take(4))
                              GestureDetector(
                                onTap: () =>
                                    context.go(RevealScreen.routePath, extra: note),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border:
                                        Border.all(color: AppColors.softStroke),
                                  ),
                                  child: Center(
                                    child: Text(
                                      note.type.name.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add_circle),
                          label: const Text("Add more favorites"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.mutedText,
                            side: const BorderSide(color: AppColors.softStroke),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        if (_selected != null) ...[
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () => context.go(
                              RevealScreen.routePath,
                              extra: _selected,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border:
                                    Border.all(color: AppColors.softStroke),
                              ),
                              child: Text(
                                _selected!.text ?? "Favorite note",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const EmptyState(
                    title: "Couldn't load favorites",
                    subtitle: "Try again later.",
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

class _JarCard extends StatelessWidget {
  const _JarCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.7),
              Colors.white.withOpacity(0.2)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 60,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Center(
          child: Icon(Icons.local_florist,
              size: 120, color: AppColors.primary.withOpacity(0.6)),
        ),
      ),
    );
  }
}
