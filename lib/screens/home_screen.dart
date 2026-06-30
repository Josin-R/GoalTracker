import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../services/goals_provider.dart';
import '../services/language_provider.dart';
import '../theme.dart';
import '../widgets/goal_progress_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting(String lang) {
    final hour = DateTime.now().hour;
    if (lang == 'fr') {
      if (hour < 12) return 'Bonjour 🌅';
      if (hour < 18) return 'Bonne après-midi ☀️';
      return 'Bonsoir 🌙';
    } else {
      if (hour < 12) return 'Good morning 🌅';
      if (hour < 18) return 'Good afternoon ☀️';
      return 'Good evening 🌙';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final lang = ref.watch(languageProvider);
    final notifier = ref.read(goalsProvider.notifier);
    final streak = notifier.streak;
    final rate = notifier.successRate;
    final points = notifier.totalPoints;
    final surface = Theme.of(context).cardColor;
    final border = Theme.of(context).dividerColor;
    final muted = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF484F58) : const Color(0xFF8C959F);
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE6EDF3) : const Color(0xFF24292F);

    final activeGoals = goals.where((g) => !g.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(lang),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700, color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                '${activeGoals.length} ${lang == 'fr' ? 'objectif(s) actif(s)' : 'active goal(s)'}',
                style: TextStyle(fontSize: 13, color: muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FadeInDown(
          delay: const Duration(milliseconds: 100),
          child: Row(
            children: [
              _StatBox(
                label: AppStrings.get('streak', lang),
                value: '$streak ${lang == 'fr' ? 'j' : 'd'}',
                surface: surface, border: border,
              ),
              const SizedBox(width: 10),
              _StatBox(
                label: AppStrings.get('reussite', lang),
                value: '${(rate * 100).toInt()}%',
                surface: surface, border: border,
              ),
              const SizedBox(width: 10),
              _StatBox(
                label: AppStrings.get('points', lang),
                value: '$points',
                surface: surface, border: border,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppStrings.get('objectifs_du_jour', lang),
          style: TextStyle(
              fontSize: 11, color: muted,
              fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        const SizedBox(height: 10),
        if (activeGoals.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Center(child: Text(
              lang == 'fr' ? 'Ajoutez votre premier objectif !' : 'Add your first goal!',
              style: TextStyle(color: muted, fontSize: 13),
            )),
          )
        else
          ...activeGoals.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FadeInUp(child: GoalProgressCard(goal: g, showActions: true)),
          )),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color surface, border;
  const _StatBox({
    required this.label, required this.value,
    required this.surface, required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF484F58) : const Color(0xFF8C959F);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: kAccent)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: muted)),
        ]),
      ),
    );
  }
}
