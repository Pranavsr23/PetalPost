import "package:flutter/material.dart";

class AppColors {
  static const Color primary = Color(0xFFEE2B5B);
  static const Color primaryDark = Color(0xFFD61F4B);
  static const Color petalDark = Color(0xFF5E112D);
  static const Color petalLight = Color(0xFFF47C66);
  static const Color backgroundLight = Color(0xFFF8F6F6);
  static const Color backgroundDark = Color(0xFF221015);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF361B21);
  static const Color blushLight = Color(0xFFFFDBE4);
  static const Color blushMid = Color(0xFFFFEFEF);
  static const Color ink = Color(0xFF221015);
  static const Color mutedText = Color(0xFF8B7D83);
  static const Color softStroke = Color(0xFFF1E7EA);
  static const Color success = Color(0xFF34C38F);
  static const Color warning = Color(0xFFF4B740);
}

class AppGradients {
  static const LinearGradient blushBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.4, 1.0],
    colors: [
      AppColors.blushLight,
      AppColors.surfaceLight,
      AppColors.blushMid,
    ],
  );

  static const LinearGradient primaryGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.petalLight,
    ],
  );
}
