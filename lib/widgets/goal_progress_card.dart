import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal.dart';
import '../services/goals_provider.dart';
import '../services/language_provider.dart';
import '../theme.dart';

class GoalProgressCard extends ConsumerWidget {
  final Goal goal;
  final bool showSteps;
  final bool showActions;

  const GoalProgressCard({
    super.key,
    required this.goal,
    this.showSteps = false,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final surface = Theme.of(context).cardColor;
    final border = Theme.of(context).dividerColor;
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE6EDF3) : const Color(0xFF24292F);
    final muted = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF484F58) : const Color(0xFF8C959F);

    return GestureDetector(
      onLongPress: showActions ? () => _showOptionsMenu(context, ref, lang) : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(goal.title,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kAccent.withValues(alpha: 0.5)),
                  ),
                  child: Text(goal.category,
                      style: const TextStyle(fontSize: 9, color: kAccent, fontWeight: FontWeight.w600)),
                ),
                if (showActions) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _showOptionsMenu(context, ref, lang),
                    child: Icon(Icons.more_vert, size: 18, color: muted),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: border,
                    valueColor: const AlwaysStoppedAnimation<Color>(kAccent),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${(goal.progress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 11, color: kAccent, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 6),
            Text(
              '${goal.completedSteps}/${goal.steps.length} ${lang == 'fr' ? 'etapes' : 'steps'} · ${goal.category}',
              style: TextStyle(fontSize: 10, color: muted),
            ),
            if (showSteps && goal.steps.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: goal.steps.map((step) => GestureDetector(
                  onTap: () => ref.read(goalsProvider.notifier).toggleStep(goal, step),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: step.isDone ? kAccent.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: step.isDone ? kAccent.withValues(alpha: 0.5) : border),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        step.isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
                        size: 12,
                        color: step.isDone ? kAccent : muted,
                      ),
                      const SizedBox(width: 4),
                      Text(step.title,
                          style: TextStyle(
                            fontSize: 10,
                            color: step.isDone ? kAccent : textColor,
                            decoration: step.isDone ? TextDecoration.lineThrough : null,
                          )),
                    ]),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref, String lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(goal.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  textAlign: TextAlign.center),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: kAccent),
              title: Text(lang == 'fr' ? 'Modifier' : 'Edit',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context, ref, lang);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: Colors.red.shade600),
              title: Text(lang == 'fr' ? 'Supprimer' : 'Delete',
                  style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _confirmAndDelete(context, ref, lang);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, String lang) {
    final titleCtrl = TextEditingController(text: goal.title);
    final descCtrl = TextEditingController(text: goal.description);
    String selectedCategory = goal.category;
    final categories = ['Sport', 'Finance', 'Education', 'Sante', 'Travail', 'Personnel'];
    final steps = goal.steps.map((s) => s.title).toList();
    final stepCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(lang == 'fr' ? 'Modifier' : 'Edit goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: lang == 'fr' ? 'Titre' : 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: InputDecoration(labelText: lang == 'fr' ? 'Description' : 'Description'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(labelText: lang == 'fr' ? 'Categorie' : 'Category'),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => selectedCategory = v!),
                ),
                const SizedBox(height: 16),
                Text(lang == 'fr' ? 'Micro-etapes' : 'Micro-steps',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
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
                goal.title = titleCtrl.text.trim();
                goal.description = descCtrl.text.trim();
                goal.category = selectedCategory;
                final existingTitles = goal.steps.map((s) => s.title).toList();
                for (final t in steps) {
                  if (!existingTitles.contains(t)) {
                    goal.steps.add(MicroStep(title: t, points: 10));
                  }
                }
                goal.steps.removeWhere((s) => !steps.contains(s.title));
                ref.read(goalsProvider.notifier).updateGoal(goal);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(lang == 'fr' ? 'Objectif modifie !' : 'Goal updated!'),
                ));
              },
              child: Text(lang == 'fr' ? 'Sauvegarder' : 'Save',
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAndDelete(BuildContext context, WidgetRef ref, String lang) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(lang == 'fr' ? 'Supprimer ?' : 'Delete?'),
        content: Text(
          lang == 'fr' ? '"${goal.title}" sera supprime.' : '"${goal.title}" will be deleted.',
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
    );
    if (confirmed == true) {
      ref.read(goalsProvider.notifier).deleteGoal(goal.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(lang == 'fr' ? 'Objectif supprime' : 'Goal deleted'),
        ));
      }
    }
  }
}
