import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/goal.dart';
import '../services/goals_provider.dart';
import '../services/language_provider.dart';
import '../theme.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final lang = ref.watch(languageProvider);
    final surface = Theme.of(context).cardColor;
    final border = Theme.of(context).dividerColor;
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE6EDF3) : const Color(0xFF24292F);
    final muted = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF484F58) : const Color(0xFF8C959F);

    final catMap = <String, double>{};
    for (final g in goals) {
      catMap[g.category] = (catMap[g.category] ?? 0) + g.progress;
    }

    final weekData = _buildWeekData(goals);
    final weekDaysFr = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final weekDaysEn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final weekDays = lang == 'fr' ? weekDaysFr : weekDaysEn;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              lang == 'fr' ? 'Progression cette semaine' : 'This week\'s progress',
              style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= 7) return const SizedBox();
                      return Text(weekDays[i], style: TextStyle(fontSize: 10, color: muted));
                    },
                  )),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) => BarChartGroupData(
                  x: i,
                  barRods: [BarChartRodData(
                    toY: weekData[i],
                    color: kAccent.withValues(alpha: weekData[i] > 0.5 ? 1.0 : 0.4),
                    width: 18,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  )],
                )),
              )),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Text(
          lang == 'fr' ? 'Par catégorie' : 'By category',
          style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        const SizedBox(height: 10),
        if (catMap.isEmpty)
          Center(child: Text(
            lang == 'fr' ? 'Aucune donnée encore' : 'No data yet',
            style: TextStyle(color: muted),
          ))
        else
          ...catMap.entries.map((e) {
            final total = goals.where((g) => g.category == e.key).length;
            final avg = total > 0 ? e.value / total : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(e.key, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
                    Text('${(avg * 100).toInt()}%',
                        style: const TextStyle(fontSize: 12, color: kAccent, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: avg, backgroundColor: border,
                      valueColor: const AlwaysStoppedAnimation<Color>(kAccent),
                      minHeight: 6,
                    ),
                  ),
                ]),
              ),
            );
          }),
      ],
    );
  }

  List<double> _buildWeekData(List<Goal> goals) {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: today.weekday - 1 - i));
      final allSteps = goals.expand((g) => g.steps).toList();
      final done = allSteps.where((s) =>
          s.isDone && s.completedAt != null &&
          s.completedAt!.year == day.year &&
          s.completedAt!.month == day.month &&
          s.completedAt!.day == day.day).length;
      final total = allSteps.length;
      if (total == 0) return 0.0;
      return (done / total).clamp(0.0, 1.0);
    });
  }
}
