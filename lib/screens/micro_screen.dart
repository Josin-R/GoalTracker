import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../services/goals_provider.dart';
import '../services/language_provider.dart';
import '../theme.dart';

class MicroScreen extends ConsumerWidget {
  const MicroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final lang = ref.watch(languageProvider);
    final notifier = ref.read(goalsProvider.notifier);
    final streak = notifier.streak;
    final surface = Theme.of(context).cardColor;
    final border = Theme.of(context).dividerColor;
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE6EDF3) : const Color(0xFF24292F);
    final muted = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF484F58) : const Color(0xFF8C959F);

    final today = DateTime.now();
    final weekDays = lang == 'fr'
        ? ['L', 'M', 'M', 'J', 'V', 'S', 'D']
        : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final allSteps = goals.expand((g) => g.steps.map((s) => MapEntry(g, s))).toList();
    final hasSteps = allSteps.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Streak banner
        FadeInDown(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kAccent.withValues(alpha: 0.5)),
            ),
            child: Row(children: [
              Text('$streak', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: kAccent)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(lang == 'fr' ? 'jours de streak' : 'day streak',
                    style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                Text(lang == 'fr' ? 'Continuez votre série !' : 'Keep your streak going!',
                    style: TextStyle(fontSize: 11, color: muted)),
              ]),
              const Spacer(),
              const Icon(Icons.local_fire_department_rounded, color: kAccent, size: 32),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        // Days row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final day = today.subtract(Duration(days: today.weekday - 1 - i));
            final hasActivity = goals.any((g) => g.steps.any((s) =>
                s.isDone && s.completedAt != null && _sameDay(s.completedAt!, day)));
            final isToday = _sameDay(day, today);
            return Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday ? kAccent : (hasActivity ? kAccent.withValues(alpha: 0.15) : surface),
                border: Border.all(color: hasActivity || isToday ? kAccent : border),
              ),
              child: Center(child: Text(weekDays[i],
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: isToday ? Colors.white : (hasActivity ? kAccent : muted)))),
            );
          }),
        ),
        const SizedBox(height: 20),
        Text(lang == 'fr' ? 'Micro-étapes du jour' : "Today's micro-steps",
            style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 10),

        if (goals.isEmpty)
          _EmptyHint(
            icon: Icons.add_circle_outline_rounded,
            title: lang == 'fr' ? 'Aucun objectif créé' : 'No goal created',
            subtitle: lang == 'fr'
                ? 'Allez dans "Objectifs" et créez un objectif avec des micro-étapes.'
                : 'Go to "Goals" and create a goal with micro-steps.',
          )
        else if (!hasSteps)
          _EmptyHint(
            icon: Icons.checklist_rounded,
            title: lang == 'fr' ? 'Aucune étape définie' : 'No steps defined',
            subtitle: lang == 'fr'
                ? 'Votre objectif n\'a pas de micro-étapes.\n\nComment faire :\n1. Allez dans "Objectifs"\n2. Supprimez l\'objectif actuel\n3. Recréez-le en ajoutant des étapes\n   (ex: "Courir 10 min", "Boire de l\'eau")'
                : 'Your goal has no micro-steps.\n\nHow to fix:\n1. Go to "Goals"\n2. Delete the current goal\n3. Recreate it with steps\n   (e.g. "Run 10 min", "Drink water")',
          )
        else
          ...allSteps.map((entry) {
            final goal = entry.key;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FadeInUp(
                child: GestureDetector(
                  onTap: () => ref.read(goalsProvider.notifier).toggleStep(goal, step),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: step.isDone ? kAccent.withValues(alpha: 0.4) : border),
                    ),
                    child: Row(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: step.isDone ? kAccent : Colors.transparent,
                          border: Border.all(color: step.isDone ? kAccent : border, width: 1.5),
                        ),
                        child: step.isDone ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(step.title, style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500, color: textColor,
                          decoration: step.isDone ? TextDecoration.lineThrough : null,
                        )),
                        Text(goal.title, style: TextStyle(fontSize: 10, color: muted)),
                      ])),
                      Text('+${step.points} pts',
                          style: const TextStyle(fontSize: 11, color: kAccent, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyHint({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).cardColor;
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE6EDF3) : const Color(0xFF24292F);
    final muted = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF484F58) : const Color(0xFF8C959F);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kAccent.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        Icon(icon, color: kAccent, size: 36),
        const SizedBox(height: 12),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(fontSize: 12, color: muted, height: 1.6), textAlign: TextAlign.left),
      ]),
    );
  }
}
