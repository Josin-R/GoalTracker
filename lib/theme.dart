import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kAccent = Color(0xFF1550BD);
const kAccentLight = Color(0xFF2060D4);

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D1117),
    colorScheme: const ColorScheme.dark(
      primary: kAccent,
      surface: Color(0xFF161B22),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0D1117),
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(
        color: const Color(0xFFE6EDF3),
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Color(0xFFE6EDF3)),
    ),
    cardColor: const Color(0xFF161B22),
    dividerColor: const Color(0xFF30363D),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF161B22),
      selectedItemColor: kAccent,
      unselectedItemColor: Color(0xFF484F58),
    ),
  );
}

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF6F8FA),
    colorScheme: const ColorScheme.light(
      primary: kAccent,
      surface: Color(0xFFFFFFFF),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF6F8FA),
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(
        color: const Color(0xFF24292F),
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF24292F)),
    ),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFD0D7DE),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: kAccent,
      unselectedItemColor: Color(0xFF8C959F),
    ),
  );
}
