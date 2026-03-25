import 'package:flutter/material.dart';

// ─── Vivid Colour Palette ─────────────────────────────────────────────────────
class VividColors {
  VividColors._();

  static const Color electric     = Color(0xFF6C63FF);
  static const Color neonPink     = Color(0xFFFF2E93);
  static const Color cyan         = Color(0xFF00E5FF);
  static const Color lime         = Color(0xFF76FF03);
  static const Color gold         = Color(0xFFFFD600);
  static const Color coral        = Color(0xFFFF6B6B);
  static const Color teal         = Color(0xFF1DE9B6);
  static const Color sunset       = Color(0xFFFF8A65);
  static const Color lavender     = Color(0xFFB388FF);
  static const Color emerald      = Color(0xFF00E676);
  static const Color hotPink      = Color(0xFFFF4081);
  static const Color skyBlue      = Color(0xFF40C4FF);
  static const Color white        = Color(0xFFFFFFFF);
  static const Color white70      = Color(0xB3FFFFFF);
  static const Color white50      = Color(0x80FFFFFF);
  static const Color white30      = Color(0x4DFFFFFF);
  static const Color darkBg       = Color(0xFF0D0D1A);
}

// ─── Slide Gradient Themes ────────────────────────────────────────────────────
class SlideGradients {
  SlideGradients._();

  static const List<List<Color>> themes = [
    // 0: Deep Electric Purple → Hot Pink
    [Color(0xFF1A0533), Color(0xFF4A148C), Color(0xFFAD1457)],
    // 1: Ocean Teal → Cyan
    [Color(0xFF002B36), Color(0xFF00695C), Color(0xFF00BFA5)],
    // 2: Sunset Gold → Coral
    [Color(0xFF1A0A00), Color(0xFFBF360C), Color(0xFFFF8F00)],
    // 3: Deep Blue → Electric
    [Color(0xFF0D1B2A), Color(0xFF1B3A6B), Color(0xFF6C63FF)],
    // 4: Emerald → Lime
    [Color(0xFF002200), Color(0xFF1B5E20), Color(0xFF76FF03)],
    // 5: Magenta → Lavender
    [Color(0xFF1A002B), Color(0xFF880E4F), Color(0xFFCE93D8)],
    // 6: Crimson → Gold
    [Color(0xFF1A0008), Color(0xFFB71C1C), Color(0xFFFFD600)],
    // 7: Midnight → Cyan
    [Color(0xFF000A12), Color(0xFF01579B), Color(0xFF00E5FF)],
  ];

  static List<Color> forIndex(int index) =>
      themes[index % themes.length];
}

// ─── Legacy colours (kept for admin screen) ──────────────────────────────────
class BISLColors {
  BISLColors._();
  static const Color bgDeepNavy    = Color(0xFF060A1A);
  static const Color bgMidBlue     = Color(0xFF0A1628);
  static const Color royalBlue     = Color(0xFF1A3E8F);
  static const Color schoolGold    = Color(0xFFD4AF37);
  static const Color glowBlue      = Color(0xFF4A90E2);
  static const Color glowGreen     = Color(0xFF50C878);
  static const Color glowGold      = Color(0xFFFFD700);
  static const Color glowCopper    = Color(0xFFE08040);
  static const Color textPrimary   = Color(0xFFECEFF9);
  static const Color textSecondary = Color(0xFFB0B8D0);
  static const Color textMuted     = Color(0xFF6B7A9A);
  static const Color textGold      = Color(0xFFD4AF37);
  static const Color glassFill     = Color(0x18FFFFFF);
  static const Color glassBorder   = Color(0x30FFFFFF);
  static const Color periodGreen   = Color(0xFF2ECC71);
  static const Color periodYellow  = Color(0xFFF39C12);
  static const Color periodRed     = Color(0xFFE74C3C);
}

class BISLGradients {
  BISLGradients._();
  static const LinearGradient goldShimmer = LinearGradient(
    colors: [Color(0xFFB8860B), Color(0xFFD4AF37), Color(0xFFFFD700), Color(0xFFD4AF37)],
    stops: [0.0, 0.3, 0.6, 1.0],
  );
}

// ─── App Constants ─────────────────────────────────────────────────────────────
class AppConstants {
  AppConstants._();

  static const String adminPassword       = '78611051214';
  static const String schoolName          = 'The British International School of Lubumbashi';
  static const String schoolNameShort     = 'BIS Lubumbashi';
  static const String schoolCity          = 'Lubumbashi';
  static const String schoolMotto         = 'Aiming for Excellence';
  static const String schoolWebsite       = 'www.britishinternationalschool.org';
  static const String developedBy         = 'Developed by BIS IT Department';
  static const String appName             = 'BIS Display';

  // Slideshow defaults
  static const int defaultSlideSeconds    = 10;
  static const int minSlideSeconds        = 5;
  static const int maxSlideSeconds        = 60;

  // Content rotation
  static const int quoteRotationSeconds   = 180;
  static const int factRotationSeconds    = 45;
  static const int onThisDayDuration      = 30;

  // Particles
  static const int particleCount         = 35;

  // Music
  static const int musicFadeInSeconds    = 3;
  static const int musicFadeOutSeconds   = 2;
  static const int musicCrossfadeMs      = 2000;
  static const String musicSubDir        = 'BISL_Display/music';

  // DB
  static const String dbName             = 'bisl_display.db';
  static const int dbVersion             = 3;
}

// ─── Fonts ────────────────────────────────────────────────────────────────────
class AppFonts {
  AppFonts._();
  static const String heading   = 'Cinzel';
  static const String clock     = 'Orbitron';
  static const String body      = 'Lato';
  static const String quote     = 'Playfair Display';
}
