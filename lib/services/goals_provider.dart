import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/goal.dart';

final goalsProvider = StateNotifierProvider<GoalsNotifier, List<Goal>>((ref) {
  return GoalsNotifier();
});

final themeProvider = StateProvider<bool>((ref) => true);

class GoalsNotifier extends StateNotifier<List<Goal>> {
  late Box<Goal> _box;

  GoalsNotifier() : super([]) {
    _box = Hive.box<Goal>('goals');
    state = _box.values.toList();
  }

  void addGoal(Goal goal) {
    _box.put(goal.id, goal);
    state = _box.values.toList();
  }

  void updateGoal(Goal goal) {
    _box.put(goal.id, goal);
    goal.save();
    state = _box.values.toList();
  }

  void deleteGoal(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }

  void toggleStep(Goal goal, MicroStep step) {
    step.isDone = !step.isDone;
    step.completedAt = step.isDone ? DateTime.now() : null;
    goal.save();
    state = _box.values.toList();
  }

  int get totalPoints {
    return state.fold<int>(0, (sum, g) =>
        sum + g.steps.where((s) => s.isDone).fold<int>(0, (s2, step) => s2 + step.points));
  }

  int get streak {
    int s = 0;
    final today = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final day = today.subtract(Duration(days: i));
      final has = state.any((g) => g.steps.any((step) =>
          step.isDone &&
          step.completedAt != null &&
          _sameDay(step.completedAt!, day)));
      if (has) {
        s++;
      } else if (i > 0) {
        break;
      }
    }
    return s;
  }

  double get successRate {
    final total = state.fold<int>(0, (sum, g) => sum + g.steps.length);
    final done = state.fold<int>(0, (sum, g) => sum + g.completedSteps);
    if (total == 0) return 0;
    return done / total;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
