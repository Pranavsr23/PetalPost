import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../core/theme/app_colors.dart";
import "../../data/models/note.dart";
import "../../data/models/note_type.dart";
import "../../providers/app_state_providers.dart";
import "../../providers/data_providers.dart";
import "../../shared/widgets/empty_state.dart";
import "../../shared/widgets/waveform_bar.dart";
import "../home/widgets/home_bottom_nav.dart";
import "../notes/compose_note_screen.dart";
import "../reveal/reveal_screen.dart";

class MemoriesScreen extends ConsumerStatefulWidget {
  const MemoriesScreen({super.key});

  static const String routePath = "/memories";

  @override
  ConsumerState<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends ConsumerState<MemoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 1;
  int _selectedFilter = 1;

  final List<_FilterChipData> _filters = const [
    _FilterChipData(label: "Space", icon: Icons.expand_more),
    _FilterChipData(label: "Type", icon: Icons.expand_more),
    _FilterChipData(label: "Surprise", icon: Icons.expand_more),
    _FilterChipData(label: "Time Capsule", icon: Icons.expand_more),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final space = ref.watch(selectedSpaceProvider);
    if (space == null) {
      return const Scaffold(
        body: Center(
          child:
              EmptyState(title: "No space", subtitle: "Create a space first."),
        ),
      );
    }

    final notesAsync = ref.watch(notesProvider(space.id));
    final favoritesAsync = ref.watch(favoriteNotesProvider(space.id));
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    final isFavorites = _selectedTab == 0;
    final dataAsync = isFavorites ? favoritesAsync : notesAsync;

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
          child: const Icon(Icons.edit, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: HomeBottomNav(
        activeIndex: 1,
        onHome: () => context.go("/home"),
        onMemories: () {},
        onRewards: () => context.go("/rewards"),
        onSettings: () => context.go("/settings"),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                "Memories",
                style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.softStroke),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentTab(
                        label: "Favorites",
                        isActive: _selectedTab == 0,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                    ),
                    Expanded(
                      child: _SegmentTab(
                        label: "All",
                        isActive: _selectedTab == 1,
                        onTap: () => setState(() => _selectedTab = 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.softStroke),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: "Search your love notes...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isActive = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.softStroke),
                      ),
                      child: Row(
                        children: [
                          Text(
                            filter.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isActive ? Colors.white : AppColors.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            filter.icon,
                            size: 18,
                            color: isActive ? Colors.white : AppColors.mutedText,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: dataAsync.when(
                data: (notes) {
                  if (notes.isEmpty) {
                    return const Center(
                      child: EmptyState(
                        title: "No memories yet",
                        subtitle: "Send notes to build your collection.",
                      ),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 16.0;
                      final itemWidth = (constraints.maxWidth - spacing) / 2;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                        child: Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (var i = 0; i < notes.length; i++)
                              SizedBox(
                                width: itemWidth,
                                child: _MemoryCard(
                                  note: notes[i],
                                  height: _heightFor(notes[i], i),
                                  isFavorite: currentUser != null &&
                                      notes[i]
                                          .isFavoriteBy
                                          .containsKey(currentUser.uid),
                                  onTap: () => context.go(
                                    RevealScreen.routePath,
                                    extra: notes[i],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) => const Center(
                  child: EmptyState(
                    title: "Couldn't load memories",
                    subtitle: "Try again later.",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _heightFor(Note note, int index) {
    if (note.isLocked) return 220;
    if (note.type == NoteType.handwriting) return 240;
    if (note.type == NoteType.voice) return 200;
    return index.isEven ? 190 : 210;
  }
}

class _FilterChipData {
  const _FilterChipData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isActive ? Colors.white : AppColors.mutedText,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.note,
    required this.height,
    required this.isFavorite,
    required this.onTap,
  });

  final Note note;
  final double height;
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.softStroke),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _MemoryPreview(note: note),
                  ),
                  if (isFavorite)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _titleFor(note),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              _typeLabel(note),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: note.isLocked || note.surprise
                        ? AppColors.primary
                        : AppColors.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(Note note) {
    if (note.isLocked) return "Time Capsule";
    if (note.surprise) return "Surprise";
    switch (note.type) {
      case NoteType.handwriting:
        return "Handwriting";
      case NoteType.voice:
        return "Voice Note";
      case NoteType.text:
        return "Text";
    }
  }

  String _titleFor(Note note) {
    if (note.text != null && note.text!.trim().isNotEmpty) {
      return note.text!.split("\n").first;
    }
    if (note.surprise) {
      return "A little gift";
    }
    if (note.type == NoteType.handwriting) {
      return "Handwritten note";
    }
    if (note.type == NoteType.voice) {
      return "Voice note";
    }
    return "Love note";
  }
}

class _MemoryPreview extends StatelessWidget {
  const _MemoryPreview({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final imageUrl = note.imageUrl ?? note.thumbnailUrl;
    if (note.isLocked) {
      final unlockAt = note.unlockAt;
      final daysLeft =
          unlockAt == null ? null : unlockAt.difference(DateTime.now()).inDays;
      final label = daysLeft == null || daysLeft <= 0
          ? "Opens soon"
          : "Opens in $daysLeft days";
      return Container(
        color: const Color(0xFFF0EDEE),
        child: Stack(
          children: [
            if (imageUrl != null)
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.25),
                  colorBlendMode: BlendMode.darken,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFEAE6E8),
                  ),
                ),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock, color: Colors.white, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (note.surprise) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAD0D9), Color(0xFFFCE6EC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.redeem, color: AppColors.primary, size: 40),
        ),
      );
    }

    if (note.type == NoteType.handwriting && imageUrl != null) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _fallbackImage();
        },
      );
    }

    if (note.type == NoteType.voice) {
      final duration = note.audioDurationSec ?? 0;
      return Stack(
        children: [
          Container(
            color: AppColors.primary.withOpacity(0.08),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  WaveformBar(
                    peaks: note.waveformPeaks ?? const [2, 4, 6, 8, 5, 3],
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _formatDuration(duration),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic, color: AppColors.primary, size: 14),
            ),
          ),
        ],
      );
    }

    if (note.type == NoteType.text) {
      return Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0xFFFFF0F5),
        child: Center(
          child: Text(
            note.text ?? "",
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ),
      );
    }

    return _fallbackImage();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(1, "0");
    final remaining = (seconds % 60).toString().padLeft(2, "0");
    return "$minutes:$remaining";
  }

  Widget _fallbackImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFDBE4), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.redeem, color: AppColors.primary, size: 32),
      ),
    );
  }
}
