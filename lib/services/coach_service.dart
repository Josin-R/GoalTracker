import '../models/goal.dart';

class CoachInsight {
  final String tag;
  final String message;
  final String color;
  const CoachInsight({required this.tag, required this.message, required this.color});
}

class CoachService {
  static List<CoachInsight> analyze(List<Goal> goals, {String lang = 'fr'}) {
    final insights = <CoachInsight>[];

    if (goals.isEmpty) {
      insights.add(CoachInsight(
        tag: lang == 'fr' ? 'Bienvenue' : 'Welcome',
        message: lang == 'fr'
            ? "Commencez par ajouter votre premier objectif avec des micro-étapes !"
            : "Start by adding your first goal with micro-steps!",
        color: 'blue',
      ));
      return insights;
    }

    final streak = _calculateStreak(goals);
    if (streak >= 7) {
      insights.add(CoachInsight(
        tag: lang == 'fr' ? 'Streak incroyable' : 'Amazing streak',
        message: lang == 'fr'
            ? "$streak jours de suite ! Tu es dans une lancée exceptionnelle. Continue !"
            : "$streak days in a row! You're on an exceptional roll. Keep going!",
        color: 'green',
      ));
    } else if (streak >= 3) {
      insights.add(CoachInsight(
        tag: lang == 'fr' ? 'Bonne série' : 'Good streak',
        message: lang == 'fr'
            ? "$streak jours consécutifs accomplis. Tu construis une vraie habitude !"
            : "$streak consecutive days done. You're building a real habit!",
        color: 'green',
      ));
    } else if (streak == 0) {
      insights.add(CoachInsight(
        tag: lang == 'fr' ? 'Nouveau départ' : 'Fresh start',
        message: lang == 'fr'
            ? "Aujourd'hui est une nouvelle chance. Un seul objectif accompli suffit pour relancer ta série !"
            : "Today is a new chance. Just one completed goal is enough to restart your streak!",
        color: 'orange',
      ));
    }

    final rate = _globalSuccessRate(goals);
    if (rate >= 0.8) {
      insights.add(CoachInsight(
        tag: lang == 'fr' ? 'Excellente performance' : 'Excellent performance',
        message: lang == 'fr'
            ? "Ton taux de réussite est remarquable. Tu maîtrises parfaitement tes objectifs !"
            : "Your success rate is remarkable. You're perfectly mastering your goals!",
        color: 'green',
      ));
    } else if (rate < 0.3 && goals.isNotEmpty) {
      insights.add(CoachInsight(
        tag: lang == 'fr' ? 'Conseil' : 'Tip',
        message: lang == 'fr'
            ? "Tes objectifs semblent ambitieux. Essaie de découper chaque étape en actions encore plus petites."
            : "Your goals seem ambitious. Try breaking each step into even smaller actions.",
        color: 'orange',
      ));
    }

    for (final goal in goals) {
      if (!goal.isCompleted && goal.progress >= 0.7 && goal.progress < 1.0) {
        insights.add(CoachInsight(
          tag: lang == 'fr' ? 'Presque terminé' : 'Almost done',
          message: lang == 'fr'
              ? "\"${goal.title}\" est à ${(goal.progress * 100).toInt()}%. Il te reste ${goal.steps.length - goal.completedSteps} étape(s) — tu y es presque !"
              : "\"${goal.title}\" is at ${(goal.progress * 100).toInt()}%. You have ${goal.steps.length - goal.completedSteps} step(s) left — almost there!",
          color: 'blue',
        ));
        break;
      }
    }

    final stalled = goals.where((g) => !g.isCompleted && g.progress == 0).toList();
    if (stalled.isNotEmpty) {
      insights.add(CoachInsight(
        tag: lang == 'fr' ? 'Objectif en attente' : 'Goal pending',
        message: lang == 'fr'
            ? "\"${stalled.first.title}\" n'a pas encore démarré. Commence par la toute première étape aujourd'hui !"
            : "\"${stalled.first.title}\" hasn't started yet. Begin with the very first step today!",
        color: 'orange',
      ));
    }

    final bestCat = _bestCategory(goals);
    if (bestCat != null) {
      insights.add(CoachInsight(
        tag: lang == 'fr' ? 'Point fort' : 'Strength',
        message: lang == 'fr'
            ? "Ta catégorie \"$bestCat\" est ta plus forte. Utilise cette énergie pour booster tes autres objectifs !"
            : "Your \"$bestCat\" category is your strongest. Use that energy to boost your other goals!",
        color: 'green',
      ));
    }

    if (insights.isEmpty) {
      insights.add(CoachInsight(
        tag: lang == 'fr' ? 'Analyse du jour' : 'Daily analysis',
        message: lang == 'fr'
            ? "Continue à cocher tes micro-victoires chaque jour pour progresser régulièrement."
            : "Keep checking off your micro-victories every day to progress consistently.",
        color: 'blue',
      ));
    }

    return insights.take(4).toList();
  }

  static String getDailyMotivation(List<Goal> goals, {String lang = 'fr'}) {
    final messagesFr = [
      "Chaque grande réussite commence par une décision courageuse.",
      "Tu n'as pas besoin d'être parfait, juste constant.",
      "Un pas par jour, c'est 365 pas en un an.",
      "La discipline est le pont entre tes objectifs et tes accomplissements.",
      "Commence petit, pense grand, agis maintenant.",
      "Le succès est la somme de petits efforts répétés chaque jour.",
      "Ne compare pas ta progression à celle des autres. Chacun a son rythme.",
    ];
    final messagesEn = [
      "Every great achievement starts with a courageous decision.",
      "You don't need to be perfect, just consistent.",
      "One step a day is 365 steps in a year.",
      "Discipline is the bridge between your goals and your accomplishments.",
      "Start small, think big, act now.",
      "Success is the sum of small efforts repeated every day.",
      "Don't compare your progress to others. Everyone has their own pace.",
    ];
    final messages = lang == 'fr' ? messagesFr : messagesEn;
    final today = DateTime.now().day;
    return messages[today % messages.length];
  }

  static int _calculateStreak(List<Goal> goals) {
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final day = today.subtract(Duration(days: i));
      final hasActivity = goals.any((g) => g.steps.any((s) =>
          s.isDone && s.completedAt != null && _isSameDay(s.completedAt!, day)));
      if (hasActivity) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  static double _globalSuccessRate(List<Goal> goals) {
    if (goals.isEmpty) return 0;
    final total = goals.fold<int>(0, (sum, g) => sum + g.steps.length);
    final done = goals.fold<int>(0, (sum, g) => sum + g.completedSteps);
    if (total == 0) return 0;
    return done / total;
  }

  static String? _bestCategory(List<Goal> goals) {
    final catMap = <String, List<double>>{};
    for (final g in goals) {
      catMap.putIfAbsent(g.category, () => []).add(g.progress);
    }
    String? best;
    double bestRate = 0;
    catMap.forEach((cat, rates) {
      final avg = rates.reduce((a, b) => a + b) / rates.length;
      if (avg > bestRate && avg > 0.3) { bestRate = avg; best = cat; }
    });
    return best;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
