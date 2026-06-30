import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'goal.g.dart';

@HiveType(typeId: 0)
class Goal extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late String category;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  DateTime? deadline;

  @HiveField(6)
  late List<MicroStep> steps;

  @HiveField(7)
  late bool isCompleted;

  Goal({
    String? id,
    required this.title,
    this.description = '',
    required this.category,
    DateTime? createdAt,
    this.deadline,
    List<MicroStep>? steps,
    this.isCompleted = false,
  }) {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
    this.steps = steps ?? [];
  }

  double get progress {
    if (steps.isEmpty) return 0.0;
    final done = steps.where((s) => s.isDone).length;
    return done / steps.length;
  }

  int get completedSteps => steps.where((s) => s.isDone).length;
}

@HiveType(typeId: 1)
class MicroStep extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late bool isDone;

  @HiveField(3)
  late int points;

  @HiveField(4)
  DateTime? completedAt;

  MicroStep({
    String? id,
    required this.title,
    this.isDone = false,
    this.points = 10,
    this.completedAt,
  }) {
    this.id = id ?? const Uuid().v4();
  }
}
