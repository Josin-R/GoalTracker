import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/goals_provider.dart';
import '../services/language_provider.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'goals_screen.dart';
import 'micro_screen.dart';
import 'stats_screen.dart';
import 'coach_screen.dart';
import 'settings_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    GoalsScreen(),
    MicroScreen(),
    StatsScreen(),
  ];

  List<String> _getTitles(String lang) => [
    AppStrings.get('accueil', lang),
    AppStrings.get('objectifs', lang),
    AppStrings.get('micro_victoires', lang),
    AppStrings.get('stats', lang),
  ];

  void _openCoach() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CoachScreen(),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final lang = ref.watch(languageProvider);
    final titles = _getTitles(lang);
    final surface = Theme.of(context).cardColor;
    final border = Theme.of(context).dividerColor;
    final mutedColor = isDark ? const Color(0xFF484F58) : const Color(0xFF8C959F);

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          // Toggle Nuit / Jour
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                _ThemeBtn(
                  icon: Icons.wb_sunny_rounded,
                  active: !isDark,
                  onTap: () => ref.read(themeProvider.notifier).state = false,
                ),
                _ThemeBtn(
                  icon: Icons.nightlight_round,
                  active: isDark,
                  onTap: () => ref.read(themeProvider.notifier).state = true,
                ),
              ],
            ),
          ),
          // Bouton Paramètres
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
            color: mutedColor,
          ),
        ],
      ),
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _openCoach,
        backgroundColor: kAccent,
        elevation: 6,
        child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 26),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: AppStrings.get('accueil', lang)),
          BottomNavigationBarItem(icon: const Icon(Icons.track_changes_rounded), label: lang == 'fr' ? 'Objectifs' : 'Goals'),
          BottomNavigationBarItem(icon: const Icon(Icons.star_rounded), label: lang == 'fr' ? 'Victoires' : 'Victories'),
          BottomNavigationBarItem(icon: const Icon(Icons.bar_chart_rounded), label: lang == 'fr' ? 'Stats' : 'Stats'),
        ],
      ),
    );
  }
}

class _ThemeBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ThemeBtn({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 24,
        decoration: BoxDecoration(
          color: active ? kAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 14, color: active ? Colors.white : Colors.grey),
      ),
    );
  }
}
