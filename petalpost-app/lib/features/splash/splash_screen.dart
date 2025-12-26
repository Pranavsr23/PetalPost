import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:google_fonts/google_fonts.dart";

import "../../core/theme/app_colors.dart";
import "../../providers/service_providers.dart";
import "../auth/onboarding_screen.dart";

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const String routePath = "/splash";

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final onboarding = await ref.read(onboardingServiceProvider).isComplete();
    if (!mounted) return;
    if (!onboarding) {
      context.go(OnboardingScreen.routePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.manropeTextTheme(Theme.of(context).textTheme);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.blushBackground),
        child: Theme(
          data: Theme.of(context).copyWith(textTheme: textTheme),
          child: Column(
            children: [
              const Spacer(),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                  children: const [
                    TextSpan(
                      text: "Petal",
                      style: TextStyle(color: AppColors.petalDark),
                    ),
                    TextSpan(
                      text: "Post",
                      style: TextStyle(color: AppColors.petalLight),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.mail,
                    size: 160,
                    color: const Color(0xFFEADCD7),
                  ),
                  Positioned(
                    top: 52,
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return const LinearGradient(
                          colors: [AppColors.petalLight, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(rect);
                      },
                      child:
                          const Icon(Icons.favorite, size: 64, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                "Made for two.",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedText,
                      letterSpacing: 0.6,
                    ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
