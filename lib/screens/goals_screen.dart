import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal.dart';
import '../services/goals_provider.dart';
import '../services/language_provider.dart';
import '../theme.dart';
import '../widgets/goal_progress_card.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final lang = ref.watch(languageProvider);
    final muted = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF484F58) : const Color(0xFF8C959F);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showAddGoalDialog(context, ref, lang),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                lang == 'fr' ? 'Ajouter un objectif' : 'Add a goal',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        if (goals.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Row(children: [
              Icon(Icons.swipe_left_outlined, size: 14, color: muted),
              const SizedBox(width: 4),
              Text(
                lang == 'fr' ? 'Glissez a gauche pour supprimer' : 'Swipe left to delete',
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ]),
          ),
        Expanded(
          child: goals.isEmpty
              ? Center(child: Text(
                  lang == 'fr' ? 'Aucun objectif. Ajoutez-en un !' : 'No goals yet. Add one!',
                  style: TextStyle(color: muted),
                ))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: goals.length,
                  itemBuilder: (_, i) {
                    final goal = goals[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: Key(goal.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
                              const SizedBox(height: 4),
                              Text(
                                lang == 'fr' ? 'Supprimer' : 'Delete',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        confirmDismiss: (_) async {
                          return await _confirmDelete(context, lang, goal.title);
                        },
                        onDismissed: (_) {
                          ref.read(goalsProvider.notifier).deleteGoal(goal.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(lang == 'fr'
                                ? '"${goal.title}" supprime'
                                : '"${goal.title}" deleted'),
                          ));
                        },
                        child: GoalProgressCard(goal: goal, showSteps: true, showActions: true),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String lang, String title) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(lang == 'fr' ? 'Supprimer cet objectif ?' : 'Delete this goal?'),
            content: Text(
              lang == 'fr'
                  ? '"$title" sera definitvement supprime.'
                  : '"$title" will be permanently deleted.',
              style: const TextStyle(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(lang == 'fr' ? 'Annuler' : 'Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                onPressed: () => Navigator.pop(context, true),
                child: Text(lang == 'fr' ? 'Supprimer' : 'Delete',
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ?? false;
  }

  void _showAddGoalDialog(BuildContext context, WidgetRef ref, String lang) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedCategory = 'Sport';
    final categories = ['Sport', 'Finance', 'Education', 'Sante', 'Travail', 'Personnel'];
    final steps = <String>[];
    final stepCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(lang == 'fr' ? 'Nouvel objectif' : 'New goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: lang == 'fr' ? 'Titre' : 'Title',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: InputDecoration(
                    labelText: lang == 'fr' ? 'Description (optionnel)' : 'Description (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: lang == 'fr' ? 'Categorie' : 'Category',
                  ),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => selectedCategory = v!),
                ),
                const SizedBox(height: 16),
                Text(
                  lang == 'fr' ? 'Micro-etapes' : 'Micro-steps',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...steps.map((s) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle_outline, color: kAccent, size: 18),
                  title: Text(s, style: const TextStyle(fontSize: 13)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => setState(() => steps.remove(s)),
                  ),
                )),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: stepCtrl,
                      decoration: InputDecoration(
                        hintText: lang == 'fr' ? 'Ajouter une etape' : 'Add a step',
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: kAccent),
                    onPressed: () {
                      if (stepCtrl.text.trim().isNotEmpty) {
                        setState(() {
                          steps.add(stepCtrl.text.trim());
                          stepCtrl.clear();
                        });
                      }
                    },
                  ),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(lang == 'fr' ? 'Annuler' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kAccent),
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final goal = Goal(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  category: selectedCategory,
                  steps: steps.asMap().entries.map((e) =>
                      MicroStep(title: e.value, points: (e.key + 1) * 10)).toList(),
                );
                ref.read(goalsProvider.notifier).addGoal(goal);
                Navigator.pop(ctx);
              },
              child: Text(lang == 'fr' ? 'Creer' : 'Create',
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
