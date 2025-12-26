import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/theme/app_colors.dart";
import "../../providers/data_providers.dart";
import "../../shared/utils/date_formatters.dart";
import "../../shared/widgets/empty_state.dart";

class AnniversaryScreen extends ConsumerStatefulWidget {
  const AnniversaryScreen({super.key});

  static const String routePath = "/anniversary";

  @override
  ConsumerState<AnniversaryScreen> createState() => _AnniversaryScreenState();
}

class _AnniversaryScreenState extends ConsumerState<AnniversaryScreen> {
  bool _countdownMode = false;
  final Set<int> _selectedOptions = {0};

  @override
  Widget build(BuildContext context) {
    final space = ref.watch(selectedSpaceProvider);
    if (space == null || space.anniversaryDate == null) {
      return const Scaffold(
        body: Center(
          child: EmptyState(
            title: "No anniversary set",
            subtitle: "Add an anniversary date in space settings.",
          ),
        ),
      );
    }

    final daysTogether =
        DateFormatters.daysTogether(space.anniversaryDate!, DateTime.now());
    final nextMilestone = DateFormatters.nextMilestoneDays(
        space.anniversaryDate!, DateTime.now());
    final milestoneTarget = daysTogether + nextMilestone;
    final progress = nextMilestone == 0 ? 1.0 : (50 - nextMilestone) / 50.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _HeroDays(daysTogether: daysTogether),
                    const SizedBox(height: 20),
                    _MilestoneCard(
                      milestoneTarget: milestoneTarget,
                      nextMilestone: nextMilestone,
                      progress: progress,
                    ),
                    const SizedBox(height: 24),
                    _WidgetSection(
                      daysTogether: daysTogether,
                      milestoneTarget: milestoneTarget,
                      spaceName: space.name,
                      countdownMode: _countdownMode,
                      onToggle: (value) {
                        setState(() => _countdownMode = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _DisplayOptions(
                      selectedOptions: _selectedOptions,
                      onTap: (index, selected) {
                        setState(() {
                          if (selected) {
                            _selectedOptions.add(index);
                          } else {
                            _selectedOptions.remove(index);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const _BottomAction(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
          const Spacer(),
          Text("Anniversary", style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
    );
  }
}

class _HeroDays extends StatelessWidget {
  const _HeroDays({required this.daysTogether});

  final int daysTogether;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            Text(
              daysTogether.toString(),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Days in love",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedText,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.calendar_month, size: 18),
          label: const Text("Edit Date"),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
            shape: const StadiumBorder(),
          ),
        ),
      ],
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.milestoneTarget,
    required this.nextMilestone,
    required this.progress,
  });

  final int milestoneTarget;
  final int nextMilestone;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Next Milestone",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedText,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$milestoneTarget Days",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                  children: [
                    TextSpan(
                      text: nextMilestone.toString(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: " days to go!"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: const Color(0xFFF0E8EB),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${(progress * 100).round()}% Complete",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.mutedText),
            ),
          ),
        ],
      ),
    );
  }
}

class _WidgetSection extends StatelessWidget {
  const _WidgetSection({
    required this.daysTogether,
    required this.milestoneTarget,
    required this.spaceName,
    required this.countdownMode,
    required this.onToggle,
  });

  final int daysTogether;
  final int milestoneTarget;
  final String spaceName;
  final bool countdownMode;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Home Screen Widget",
                style: Theme.of(context).textTheme.titleMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Preview",
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.softStroke),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE9F1FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.timer,
                    color: Color(0xFF4C7CF4), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Countdown Mode",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Switch to counting down",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.mutedText),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: countdownMode,
                onChanged: onToggle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _WidgetPreviewCard.small(daysTogether: daysTogether),
              const SizedBox(width: 16),
              _WidgetPreviewCard.medium(
                daysTogether: daysTogether,
                spaceName: spaceName,
                milestoneTarget: milestoneTarget,
              ),
              const SizedBox(width: 16),
              _WidgetPreviewCard.large(daysTogether: daysTogether),
            ],
          ),
        ),
      ],
    );
  }
}

class _DisplayOptions extends StatelessWidget {
  const _DisplayOptions({
    required this.selectedOptions,
    required this.onTap,
  });

  final Set<int> selectedOptions;
  final void Function(int index, bool selected) onTap;

  @override
  Widget build(BuildContext context) {
    const displayOptions = [
      "Show Names",
      "Show Milestone",
      "Photo Background",
      "Dark Mode",
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Display Options",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedText,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            displayOptions.length,
            (index) => ChoiceChip(
              label: Text(displayOptions[index]),
              selected: selectedOptions.contains(index),
              onSelected: (selected) => onTap(index, selected),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selectedOptions.contains(index)
                    ? Colors.white
                    : AppColors.mutedText,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.softStroke),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.ios_share),
          label: const Text("Add to Home Screen"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.ink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}

class _WidgetPreviewCard extends StatelessWidget {
  const _WidgetPreviewCard.small({
    required this.daysTogether,
  })  : _type = _PreviewType.small,
        milestoneTarget = 0,
        spaceName = "";

  const _WidgetPreviewCard.medium({
    required this.daysTogether,
    required this.spaceName,
    required this.milestoneTarget,
  }) : _type = _PreviewType.medium;

  const _WidgetPreviewCard.large({
    required this.daysTogether,
  })  : _type = _PreviewType.large,
        milestoneTarget = 0,
        spaceName = "";

  final _PreviewType _type;
  final int daysTogether;
  final int milestoneTarget;
  final String spaceName;

  @override
  Widget build(BuildContext context) {
    switch (_type) {
      case _PreviewType.small:
        return _smallCard();
      case _PreviewType.medium:
        return _mediumCard();
      case _PreviewType.large:
        return _largeCard();
    }
  }

  Widget _smallCard() {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.softStroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                daysTogether.toString(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Days",
                style: TextStyle(
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Icon(Icons.favorite, color: AppColors.primary, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mediumCard() {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -16,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spaceName.isEmpty ? "You & Partner" : spaceName,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    daysTogether.toString(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Days together",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.favorite, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Next",
                    style: TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                  Text(
                    "$milestoneTarget Days",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _largeCard() {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.softStroke),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFDBE4), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  daysTogether.toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Forever",
                  style: TextStyle(fontSize: 10, color: AppColors.mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _PreviewType { small, medium, large }
