import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../models/goal.dart';

class BackupService {
  static final _db = FirebaseFirestore.instance;

  /// Envoie tous les objectifs locaux (Hive) vers Firestore
  static Future<void> backup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Aucun utilisateur connecté');

    final box = Hive.box<Goal>('goals');
    final goals = box.values.toList();

    final goalsData = goals.map((g) => {
      'id': g.id,
      'title': g.title,
      'description': g.description,
      'category': g.category,
      'createdAt': g.createdAt.toIso8601String(),
      'deadline': g.deadline?.toIso8601String(),
      'isCompleted': g.isCompleted,
      'steps': g.steps.map((s) => {
        'id': s.id,
        'title': s.title,
        'isDone': s.isDone,
        'points': s.points,
        'completedAt': s.completedAt?.toIso8601String(),
      }).toList(),
    }).toList();

    await _db.collection('users').doc(user.uid).set({
      'goals': goalsData,
      'lastBackup': FieldValue.serverTimestamp(),
    });
  }

  /// Récupère les objectifs depuis Firestore et remplace les données locales (Hive)
  static Future<int> restore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Aucun utilisateur connecté');

    final doc = await _db.collection('users').doc(user.uid).get();

    if (!doc.exists || doc.data() == null || doc.data()!['goals'] == null) {
      return 0; // Rien à restaurer
    }

    final goalsData = doc.data()!['goals'] as List<dynamic>;

    final box = Hive.box<Goal>('goals');
    await box.clear(); // Vide les données locales actuelles

    for (final g in goalsData) {
      final steps = (g['steps'] as List<dynamic>).map((s) => MicroStep(
        id: s['id'],
        title: s['title'],
        isDone: s['isDone'] ?? false,
        points: s['points'] ?? 10,
        completedAt: s['completedAt'] != null ? DateTime.parse(s['completedAt']) : null,
      )).toList();

      final goal = Goal(
        id: g['id'],
        title: g['title'],
        description: g['description'] ?? '',
        category: g['category'],
        createdAt: DateTime.parse(g['createdAt']),
        deadline: g['deadline'] != null ? DateTime.parse(g['deadline']) : null,
        steps: steps,
        isCompleted: g['isCompleted'] ?? false,
      );

      await box.add(goal);
    }

    return goalsData.length;
  }
}