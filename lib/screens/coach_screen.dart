import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../services/coach_service.dart';
import '../services/goals_provider.dart';
import '../services/language_provider.dart';
import '../theme.dart';

class CoachScreen extends ConsumerWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final lang = ref.watch(languageProvider);
    final insights = CoachService.analyze(goals, lang: lang);
    final motivation = CoachService.getDailyMotivation(goals, lang: lang);
    final surface = Theme.of(context).cardColor;
    final border = Theme.of(context).dividerColor;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE6EDF3) : const Color(0xFF24292F);
    final muted = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF484F58) : const Color(0xFF8C959F);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: surface, border: Border(bottom: BorderSide(color: border))),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: bg, border: Border.all(color: border)),
                  child: Icon(Icons.arrow_back_rounded, size: 16, color: textColor),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kAccent, width: 1.5), color: bg),
                child: const Icon(Icons.psychology_rounded, color: kAccent, size: 20),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Coach Aria', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor)),
                Text(
                  lang == 'fr' ? 'Votre coach IA personnel' : 'Your personal AI coach',
                  style: TextStyle(fontSize: 10, color: muted),
                ),
              ]),
            ]),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              children: [
                FadeInDown(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.format_quote_rounded, color: kAccent),
                      const SizedBox(width: 10),
                      Expanded(child: Text(motivation,
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: textColor))),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  lang == 'fr' ? 'Analyse personnalisée' : 'Personalized analysis',
                  style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                const SizedBox(height: 10),
                ...insights.asMap().entries.map((e) {
                  final delay = Duration(milliseconds: 100 * e.key);
                  final insight = e.value;
                  final accentColor = insight.color == 'green'
                      ? const Color(0xFF2EA043)
                      : insight.color == 'orange'
                          ? const Color(0xFFE3A008)
                          : kAccent;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FadeInUp(
                      delay: delay,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(color: accentColor, width: 3),
                            top: BorderSide(color: border),
                            right: BorderSide(color: border),
                            bottom: BorderSide(color: border),
                          ),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(insight.tag.toUpperCase(),
                              style: TextStyle(fontSize: 9, color: accentColor,
                                  fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                          const SizedBox(height: 6),
                          Text(insight.message,
                              style: TextStyle(fontSize: 12, height: 1.5, color: textColor)),
                        ]),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
