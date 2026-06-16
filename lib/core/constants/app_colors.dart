import 'package:flutter/material.dart';

class AppColors {
  // === WARNA UTAMA UNILA ===
  static const Color primary       = Color(0xFF003087); // Biru tua Unila
  static const Color primaryLight  = Color(0xFF0050CC); // Biru medium
  static const Color primaryDark   = Color(0xFF001A5C); // Biru gelap
  static const Color accent        = Color(0xFFFFC107); // Kuning emas Unila
  static const Color accentDark    = Color(0xFFE6A800);

  // === SURFACE & BG ===
  static const Color background     = Color(0xFFF4F7FF);
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceDark    = Color(0xFF161B22);
  static const Color card           = Color(0xFFFFFFFF);
  static const Color cardDark       = Color(0xFF1C2128);

  // === TEXT ===
  static const Color textPrimary   = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint      = Color(0xFF9CA3AF);
  static const Color textInverse   = Color(0xFFFFFFFF);

  // === STATUS MARKER ===
  static const Color markerGreen  = Color(0xFF10B981); // Tersedia
  static const Color markerYellow = Color(0xFFF59E0B); // Dipesan
  static const Color markerRed    = Color(0xFFEF4444); // Penuh

  // === FUNCTIONAL ===
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF3B82F6);

  // === GRADIENTS ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
