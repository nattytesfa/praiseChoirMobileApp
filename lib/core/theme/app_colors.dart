import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2563EB); // Blue
  static const Color secondary = Color(0xFF7C3AED); // Purple
  static const Color accent = Color(0xFFFACC15);

  // Light Theme Colors
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color secondaryDark = Color.fromRGBO(109, 40, 217, 1);

  // Dark Theme Colors
  static const Color primaryLight = Color.fromARGB(255, 229, 231, 233);
  static const Color secondaryLight = Color(0xFF8B5CF6);
  static const Color fillDark = Color.fromARGB(255, 19, 30, 54);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnAppBar = Color(0xFF1E293B);
  static const Color darkSecondary = Color(0xFF03DAC6);
  static const Color darkOnSongsCard = Color(0xFF334155);
  static const Color darkError = Color(0xFFCF6679);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color.fromARGB(160, 255, 255, 255);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color white60 = Colors.white60;
  static const Color white = Color(0xFFFFFFFF);
  static const Color blue = Colors.blue;

  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color white38 = Colors.white38;

  static const Color transparent = Color(0x00000000);

  // Gray Scale
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Status Colors
  static const Color paid = Color(0xFF10B981);
  static const Color pending = Color(0xFFF59E0B);
  static const Color overdue = Color(0xFFEF4444);

  // Role Colors
  static const Color leader = Color(0xFFDC2626); // Red
  static const Color songwriter = Color(0xFF2563EB); // Blue
  static const Color prayerGroup = Color(0xFF059669); // Green
  static const Color member = Color(0xFF6B7280); // Gray

  // Language Colors
  static const Color amharic = Color(0xFFD97706); // Amber
  static const Color kembatgna = Color(0xFF7C3AED); // Purple
  static const Color english = Color(0xFF2563EB); // Blue

  // Background Colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF111827);
  static const Color onSurface = Color(0xFF111827);

  // Text Colors
  static const Color textPrimary = Colors.blueGrey;
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF9CA3AF);
  // Common border alias used across the app
  static const Color border = borderMedium;

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x66000000);

  // Helper methods
  static Color getRoleColor(String role) {
    switch (role) {
      case 'leader':
        return leader;
      case 'songwriter':
        return songwriter;
      default:
        return member;
    }
  }

  static Color getPaymentStatusColor(String status, bool isOverdue) {
    if (isOverdue) return overdue;

    switch (status) {
      case 'paid':
        return paid;
      case 'pending':
        return pending;
      case 'overdue':
        return overdue;
      default:
        return pending;
    }
  }

  static Color getLanguageColor(String language) {
    switch (language) {
      case 'amharic':
        return amharic;
      case 'kembatgna':
        return kembatgna;
      default:
        return english;
    }
  }

  static Color withValues(Color color, double opacity) {
    // Use integer alpha to avoid precision-loss deprecation warnings
    final alpha = (opacity * 255).clamp(0, 255).round();
    return color.withAlpha(alpha);
  }
}
