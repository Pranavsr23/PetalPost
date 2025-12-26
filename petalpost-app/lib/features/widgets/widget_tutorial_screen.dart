import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "../../core/theme/app_colors.dart";

class WidgetTutorialScreen extends StatefulWidget {
  const WidgetTutorialScreen({super.key});

  static const String routePath = "/widget-tutorial";

  @override
  State<WidgetTutorialScreen> createState() => _WidgetTutorialScreenState();
}

class _WidgetTutorialScreenState extends State<WidgetTutorialScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.86);
  int _platformIndex = 0;
  int _currentPage = 0;

  final List<_WidgetStep> _iosSteps = const [
    _WidgetStep(
      title: "Long press screen",
      description:
          "Press anywhere on your home screen until the apps start to jiggle.",
      icon: Icons.touch_app,
    ),
    _WidgetStep(
      title: "Tap the (+) button",
      description: "Look for the plus icon in the top left corner.",
      icon: Icons.add,
    ),
    _WidgetStep(
      title: "Search 'PetalPost'",
      description: "Pick a widget size and add it to your screen.",
      icon: Icons.search,
    ),
  ];

  final List<_WidgetStep> _androidSteps = const [
    _WidgetStep(
      title: "Long press screen",
      description: "Press and hold an empty area to open the widget menu.",
      icon: Icons.touch_app,
    ),
    _WidgetStep(
      title: "Open Widgets",
      description: "Select Widgets, then find PetalPost in the list.",
      icon: Icons.widgets,
    ),
    _WidgetStep(
      title: "Drag to home",
      description: "Choose a size and drag it onto your home screen.",
      icon: Icons.open_with,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _switchPlatform(int index) {
    setState(() {
      _platformIndex = index;
      _currentPage = 0;
    });
    _pageController.jumpToPage(0);
  }

  List<_WidgetStep> get _steps =>
      _platformIndex == 0 ? _iosSteps : _androidSteps;

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: Column(
                  children: [
                    Text(
                      "Add the widget",
                      style: theme.textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Keep your partner's notes just a glance away.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: const Color(0xFF9A4C5F)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E7EA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _PlatformTab(
                          label: "iOS",
                          isActive: _platformIndex == 0,
                          onTap: () => _switchPlatform(0),
                        ),
                      ),
                      Expanded(
                        child: _PlatformTab(
                          label: "Android",
                          isActive: _platformIndex == 1,
                          onTap: () => _switchPlatform(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 320,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _StepCard(step: _steps[index], index: index),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 10 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.preview, size: 18),
                label: const Text("Test widget preview"),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("I placed it"),
                            SizedBox(width: 8),
                            Icon(Icons.check_circle, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF9A4C5F),
                        ),
                        child: const Text("Skip for now"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WidgetStep {
  const _WidgetStep({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class _PlatformTab extends StatelessWidget {
  const _PlatformTab({
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
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isActive ? AppColors.ink : const Color(0xFF9A4C5F),
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.index});

  final _WidgetStep step;
  final int index;

  @override
  Widget build(BuildContext context) {
    final gradients = [
      const [Color(0xFFEAF2FF), Color(0xFFEFE7FF)],
      const [Color(0xFFFFE8EC), Color(0xFFFFF4F7)],
      const [Color(0xFFF2E9FF), Color(0xFFFDEBFF)],
    ];
    final gradient = gradients[index % gradients.length];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.softStroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Icon(step.icon, color: AppColors.primary, size: 42),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              step.description,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}
