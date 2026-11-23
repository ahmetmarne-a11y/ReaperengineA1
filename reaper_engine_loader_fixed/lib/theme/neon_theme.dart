import 'package:flutter/material.dart';

class NeonTheme {
  static const Color bg = Color(0xFF050A14);
  static const Color bgCard = Color(0xFF0A1628);
  static const Color neonBlue = Color(0xFF00D4FF);
  static const Color neonBlue2 = Color(0xFF0088FF);
  static const Color neonGlow = Color(0xFF00AAFF);
  static const Color textPrimary = Color(0xFFE0F4FF);
  static const Color textSecondary = Color(0xFF4A7A9B);
  static const Color border = Color(0xFF1A3A5C);

  static BoxDecoration glowBox({
    Color color = neonBlue,
    double blur = 12,
    double borderRadius = 12,
  }) {
    return BoxDecoration(
      color: bgCard,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: color.withOpacity(0.6), width: 1.2),
      boxShadow: [
        BoxShadow(
            color: color.withOpacity(0.2), blurRadius: blur, spreadRadius: 1),
        BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: blur * 2,
            spreadRadius: 2),
      ],
    );
  }

  static ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: neonBlue,
      surface: bgCard,
    ),
  );
}
