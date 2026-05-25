import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: backgroundGradientBottom,
    colorScheme: ThemeData.dark().colorScheme.copyWith(
      surface: backgroundGradientBottom,
      primary: const Color.fromARGB(255, 145, 160, 179),
      secondary: accentPrimary,
    ),
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    cardColor: cardSurface,
  );

  static const Color accentPrimary = Color(0xFF60A5FA);
  static const Color backgroundGradientTop = Color(0xFF0F172A);
  static const Color backgroundGradientBottom = Color(0xFF020617);

  static const Color backgroundSpringTop = Color(0xFF1E1B18);
  static const Color backgroundSpringBottom = Color(0xFF0A0500);
  static const Color backgroundSummerTop = Color(0xFF0F172A);
  static const Color backgroundSummerBottom = Color(0xFF020617);
  static const Color backgroundAutumnTop = Color(0xFF062419);
  static const Color backgroundAutumnBottom = Color(0xFF020C08);
  static const Color backgroundWinterTop = Color(0xFF131A35);
  static const Color backgroundWinterBottom = Color(0xFF030712);

  static const Color cardSurface = Color(0xFF161618);
  static const Color buttonSurface = Color(0xFF0F172A);
  static const Color textAccent = Colors.white60;
  static const Color textSecondary = Colors.white70;

  static const TextStyle title = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    color: Colors.white70,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle buttonTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle forecastLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle forecastTemp = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: -0.5,
  );

  static const TextStyle forecastStatus = TextStyle(
    fontSize: 11,
    color: Colors.white60,
    fontWeight: FontWeight.w400,
  );
}
