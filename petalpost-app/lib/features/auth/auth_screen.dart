import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_fonts/google_fonts.dart";

import "../../core/theme/app_colors.dart";
import "../../providers/repository_providers.dart";
import "../../providers/service_providers.dart";

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  static const String routePath = "/auth";

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isAppleLoading = false;
  bool _isGoogleLoading = false;
  String? _error;
  bool _showEmailUnavailable = false;

  Future<void> _signInWithApple() async {
    setState(() {
      _isAppleLoading = true;
      _error = null;
    });
    try {
      ref.read(analyticsServiceProvider).track("auth_apple_start");
      await ref.read(authRepositoryProvider).signInWithApple();
      ref.read(analyticsServiceProvider).track("auth_apple_success");
    } catch (error) {
      setState(() => _error = "Apple sign-in failed. Try again.");
      ref.read(analyticsServiceProvider).track("auth_apple_failed");
    } finally {
      if (mounted) {
        setState(() => _isAppleLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _error = null;
    });
    try {
      ref.read(analyticsServiceProvider).track("auth_google_start");
      await ref.read(authRepositoryProvider).signInWithGoogle();
      ref.read(analyticsServiceProvider).track("auth_google_success");
    } catch (error) {
      setState(() => _error = "Google sign-in failed. Try again.");
      ref.read(analyticsServiceProvider).track("auth_google_failed");
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  void _showEmailNotice() {
    setState(() => _showEmailUnavailable = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _showEmailUnavailable = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.manropeTextTheme(Theme.of(context).textTheme);
    return Scaffold(
      body: Stack(
        children: [
          Container(
              decoration:
                  const BoxDecoration(gradient: AppGradients.blushBackground)),
          Positioned.fill(
            child: CustomPaint(
              painter: _DotPatternPainter(
                  color: AppColors.primary.withOpacity(0.08)),
            ),
          ),
          Positioned(
            top: -80,
            right: -80,
            child: _BlurBlob(
                color: AppColors.primary.withOpacity(0.12), size: 220),
          ),
          Positioned(
            bottom: -60,
            left: -80,
            child: _BlurBlob(
                color: AppColors.primary.withOpacity(0.08), size: 260),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Theme(
                data: Theme.of(context).copyWith(textTheme: textTheme),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: AppGradients.primaryGlow,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.favorite,
                              color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Let's make a little space for love",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Sign in to sync notes between you and your partner.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_error != null || _showEmailUnavailable)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE3E6),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: const Color(0xFFF7C6D2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error ??
                                    "Email sign-in is not available yet.",
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_error != null || _showEmailUnavailable)
                      const SizedBox(height: 12),
                    _AuthButton(
                      label: "Continue with Apple",
                      icon: Icons.apple,
                      isLoading: _isAppleLoading,
                      onPressed: _isAppleLoading ? null : _signInWithApple,
                    ),
                    const SizedBox(height: 12),
                    _AuthButton(
                      label: "Continue with Google",
                      icon: Icons.g_mobiledata,
                      isLoading: _isGoogleLoading,
                      onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _showEmailNotice,
                        icon: const Icon(Icons.mail),
                        label: const Text("Continue with Email"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "By continuing, you agree to our Terms and Privacy Policy.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.mutedText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.softStroke),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({required this.color, required this.size});

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
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 80,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  _DotPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 28.0;
    for (double dx = 0; dx < size.width; dx += spacing) {
      for (double dy = 0; dy < size.height; dy += spacing) {
        canvas.drawCircle(Offset(dx, dy), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
