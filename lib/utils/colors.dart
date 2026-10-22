import 'package:flutter/material.dart';

/// Comprehensive Commercial Mobile App Design Tokens & Color Palette
class AppColors {
  // Signature Primary (Royal Deep Blue)
  static const Color primary = Color(0xFF0047BA);
  static const Color primaryDark = Color(0xFF002F87);
  static const Color primaryLight = Color(0xFFEBF3FC);
  static const Color primaryTint = Color(0xFFF0F5FF);

  // Signature Accent (Vibrant Coral Orange for CTAs & Highlights)
  static const Color accent = Color(0xFFFF5A36);
  static const Color accentOrange = Color(0xFFFF5A36);
  static const Color accentHover = Color(0xFFE04523);
  static const Color accentLight = Color(0xFFFFF2EF);

  // Clean Functional Accents
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color successLight = Color(0xFFECFDF5);
  static const Color successBorder = Color(0xFFA7F3D0);

  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);

  static const Color error = Color(0xFFEF4444); // Crimson
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFECACA);

  static const Color info = Color(0xFF0284C7); // Cyan Blue
  static const Color infoLight = Color(0xFFF0F9FF);
  static const Color infoBorder = Color(0xFFBAE6FD);

  // Backgrounds & Surface (Ultra-clean modern whites & slate grays)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderDark = Color(0xFFCBD5E1);

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnDark = Colors.white;

  // Apple iOS 18 Design Tokens (Cupertino Living)
  static const Color iosBg = Color(0xFFF2F2F7);
  static const Color iosCard = Colors.white;
  static const Color iosSystemBlue = Color(0xFF007AFF);
  static const Color iosSystemIndigo = Color(0xFF5856D6);
  static const Color iosSystemGreen = Color(0xFF34C759);
  static const Color iosSystemOrange = Color(0xFFFF9500);
  static const Color iosSystemRed = Color(0xFFFF3B30);
  static const Color iosHairline = Color(0xFFE5E5EA);
  static const Color iosLabelPrimary = Color(0xDE000000);
  static const Color iosLabelSecondary = Color(0x993C3C43);
  static const Color iosDynamicIslandBg = Color(0xFF0D0D11);

  // Role Themes
  static const Color customerTheme = Color(0xFF0047BA); // Royal Blue #0047BA
  static const Color partnerTheme = Color(0xFF0F766E); // Emerald Teal #0F766E
  static const Color partnerDark = Color(0xFF115E59);
  static const Color partnerLight = Color(0xFFF0FDFA);
  static const Color adminTheme = Color(0xFF1E293B); // Dark Navy Slate #1E293B
  static const Color adminPrimary = Color(0xFF1E293B); // Slate Navy #1E293B
  static const Color adminDark = Color(0xFF0F172A);
  static const Color whatsappGreen = Color(
    0xFF25D366,
  ); // WhatsApp Green #25D366

  // Brand Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0047BA), Color(0xFF002F87)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF5A36), Color(0xFFFF3300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient partnerGradient = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF115E59)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient adminGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bannerGradient = LinearGradient(
    colors: [Color(0xFF003B99), Color(0xFF0052CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Modern Ambient Shadows
  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.03),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> coloredShadow(
    Color color, {
    double opacity = 0.25,
    double blur = 14,
  }) => [
    BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: blur,
      offset: const Offset(0, 6),
    ),
  ];
}
