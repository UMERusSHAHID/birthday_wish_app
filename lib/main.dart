// main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Fonts ke liye package
import 'diary_page.dart'; // Nayi file jisme humara design hoga


void main() {
  // App ko poori tarah se light mode mein chalane ke liye
  runApp(const BirthdayDiaryApp());
}

class BirthdayDiaryApp extends StatelessWidget {
  const BirthdayDiaryApp({super.key});

// Main, Bold Color: Use for Headers and Confetti
  static const Color primaryLavender = Color(0xFFD87093); // Deep Rose/Berry

  // Secondary Accent: Use for Dividers, Footer, Light accents
  static const Color accentRoseGold = Color(0xFFFFB6C1); // Soft Pink/Coral

  // Background: Use for Scaffold Background
  static const Color creamBackground = Color(0xFFFFF5E1); // Warmer Cream

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Birthday Diary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Basic Theme for consistency
        primaryColor: primaryLavender,
        scaffoldBackgroundColor: creamBackground,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple, // Flutter requires a Material color
        ).copyWith(
          secondary: accentRoseGold,
        ),
        // Default Text Style (Diary ke liye)
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: const DiaryPage(), // Yahan se shuruaat hogi
    );
  }
}