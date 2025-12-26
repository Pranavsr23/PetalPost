import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";

import "../../core/theme/app_colors.dart";
import "../../providers/service_providers.dart";
import "auth_screen.dart";

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const String routePath = "/onboarding";

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _pageIndex = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      title: "Love notes on their Home Screen",
      subtitle: "Send tiny moments they will see all day.",
      imageUrl:
          "https://lh3.googleusercontent.com/aida-public/AB6AXuCqn11EYkz8tfAqsJ-L7Y3hsz0NpWC1GglcKRTAqGqRmBV7V48hCNAGSPlrgXCgpEBvsHsRiqjDUwg2gk5NbTQrKFxltLivmV6FkKntZ9g9bGVtME0N_0xisl9S1PRpI2nC_iFebxZZa-1GBzcdkUSUPkB2mMjhuYnOwj6sltdYv6tokU5GrCX6j5pLqDmhNcgAQRrymc_lKESdBJbQJ6UxrMcsXSpR-zvX_EnD_S0i1vOA-oRFMD4mvOGqkQyxQ_f3k02hN9oMoU4",
      fallbackIcon: Icons.home,
    ),
    _OnboardingPage(
      title: "Handwritten and voice love",
      subtitle: "Doodles and voice clips that feel close.",
      imageUrl:
          "https://lh3.googleusercontent.com/aida-public/AB6AXuAhCzzK95WmIJlTerMooX1L07lGo3tfQ1ce_0-PgmxBBgouVy4Sa3LVMNOM9NaJrMckde8F54SDWjGHwQ1Mk3xPJeTLgflZ1W7dgPSPSjPQe--G-ms9wW2r9sdHuvGNq2P_YoGWZ2-kKglhyxME44sBn9SmgAF_2527T5MLsNeTV0Fockca_pGSxyobHxT1743wqmwVuDmzpuatSSnNaQTekcyt1dw4nnTmJisoe4Mr1fwQcyTVNTGHNALLsYLltbg4vrR1n1llvlw",
      fallbackIcon: Icons.draw,
    ),
    _OnboardingPage(
      title: "Your moments, always",
      subtitle: "Save favorites and celebrate milestones.",
      imageUrl:
          "https://lh3.googleusercontent.com/aida-public/AB6AXuAtPjUYJLPse5Pv1IPO20td4NacUNbEC7m1540hiJCSow-4hiY0_y4byAQlWHbCcj8SFgSCPizCI7RCrAkRiZxEP1ZREXZTzqiYzlpTOuD9dPlFHEXTGN6wf9tX__mhhHmGbV1aSbyvL1OoMCzwPg5j3rxspNX-aXQkfMJ7F2wm99MeY9o45lpVSNZws7M5N1knUztIGkxDSViHpqn3wnDOJyuKSNsOnxlL4jDE8U7jcca2otlwXcVNx9TsSy5I_zEqCZYq0Yxxpgc",
      fallbackIcon: Icons.favorite,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingServiceProvider).setComplete();
    if (!mounted) return;
    context.go(AuthScreen.routePath);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.manropeTextTheme(Theme.of(context).textTheme);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.backgroundLight),
        child: SafeArea(
          child: Theme(
            data: Theme.of(context).copyWith(textTheme: textTheme),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (index) => setState(() => _pageIndex = index),
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: _OnboardingArtwork(page: page),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(32)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 24,
                                  offset: Offset(0, -8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  page.title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.displaySmall,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  page.subtitle,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.mutedText),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _pages.length,
                                    (dot) => AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      margin:
                                          const EdgeInsets.symmetric(horizontal: 4),
                                      width: _pageIndex == dot ? 24 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _pageIndex == dot
                                            ? AppColors.primary
                                            : AppColors.softStroke,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_pageIndex == _pages.length - 1) {
                                        _finish();
                                      } else {
                                        _controller.nextPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeOut,
                                        );
                                      }
                                    },
                                    child: Text(_pageIndex == _pages.length - 1
                                        ? "Get started"
                                        : "Continue"),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _finish,
                                  child: const Text("Skip"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
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

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.fallbackIcon,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final IconData fallbackIcon;
}

class _OnboardingArtwork extends StatelessWidget {
  const _OnboardingArtwork({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            page.imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return Center(
                child: Icon(page.fallbackIcon,
                    size: 120, color: AppColors.primary),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
