import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/nutri_brain_service.dart';
import '../../services/nutri_database.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  int score(NutriDaySummary brain) {
    int value = 100;
    if (brain.waterMissing > 1) value -= 20;
    if (brain.proteinMissing > 40) value -= 25;
    if (brain.availableCalories < -300) value -= 25;
    if (brain.availableCalories > 1200) value -= 10;
    return value.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: NutriDatabase().userStream(),
      builder: (context, userSnapshot) {
        final data = userSnapshot.data?.data() ?? {};
        final dailyGoal = ((data['dailyGoalCalories'] ?? 2200) as num).toInt();
        final waterGoal = ((data['waterGoalLiters'] ?? 2.9) as num).toDouble();
        final proteinGoal = ((data['proteinGoalGrams'] ?? 132) as num).toInt();
        final waterMl = ((data['waterMlToday'] ?? 0) as num).toInt();

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: NutriDatabase().mealsTodayStream(),
          builder: (context, mealsSnapshot) {
            final meals = mealsSnapshot.data?.docs ?? [];
            final kcal = meals.fold<int>(0, (sum, doc) => sum + ((doc.data()['calories'] ?? 0) as num).toInt());
            final protein = meals.fold<int>(0, (sum, doc) => sum + ((doc.data()['protein'] ?? 0) as num).toInt());

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: NutriDatabase().exercisesTodayStream(),
              builder: (context, exercisesSnapshot) {
                final exercises = exercisesSnapshot.data?.docs ?? [];
                final exercise = exercises.fold<int>(0, (sum, doc) => sum + ((doc.data()['calories'] ?? 0) as num).toInt());

                final brain = NutriDaySummary(
                  consumedCalories: kcal,
                  exerciseCalories: exercise,
                  targetCalories: dailyGoal,
                  proteinConsumed: protein,
                  proteinTarget: proteinGoal,
                  waterConsumedLiters: waterMl / 1000,
                  waterTargetLiters: waterGoal,
                );

                final note = score(brain);

                return Scaffold(
                  appBar: AppBar(title: const Text('Relatórios')),
                  body: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      const Text('Relatório MVP 1.0', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF16A34A)]),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Nota do dia', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text('$note/100', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(brain.coachMessage, style: const TextStyle(color: Colors.white)),
                        ]),
                      ),
                      const SizedBox(height: 12),
                      Card(child: ListTile(title: const Text('Calorias'), subtitle: Text('$kcal kcal consumidas • meta $dailyGoal kcal • disponíveis ${brain.availableCalories} kcal'))),
                      Card(child: ListTile(title: const Text('Proteína'), subtitle: Text('$protein g consumidas • faltam ${brain.proteinMissing} g'))),
                      Card(child: ListTile(title: const Text('Água'), subtitle: Text('${(waterMl / 1000).toStringAsFixed(1)} L consumidos • faltam ${brain.waterMissing.toStringAsFixed(1)} L'))),
                      Card(child: ListTile(title: const Text('Exercícios'), subtitle: Text('$exercise kcal gastas hoje'))),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => NutriDatabase().resetWaterToday(),
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Zerar água de hoje'),
                      ),
                      const SizedBox(height: 20),
                      const Text('Últimos 7 dias', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: NutriDatabase().mealsLastDaysStream(days: 7),
                        builder: (context, weekMealsSnapshot) {
                          final weekMeals = weekMealsSnapshot.data?.docs ?? [];
                          final totalKcal = weekMeals.fold<int>(0, (sum, doc) => sum + ((doc.data()['calories'] ?? 0) as num).toInt());
                          final totalProtein = weekMeals.fold<int>(0, (sum, doc) => sum + ((doc.data()['protein'] ?? 0) as num).toInt());
                          final avg = (totalKcal / 7).round();

                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.calendar_month),
                              title: Text('$totalKcal kcal nos últimos 7 dias'),
                              subtitle: Text('Média: $avg kcal/dia • proteína total: $totalProtein g'),
                            ),
                          );
                        },
                      ),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: NutriDatabase().exercisesLastDaysStream(days: 7),
                        builder: (context, weekExerciseSnapshot) {
                          final weekExercises = weekExerciseSnapshot.data?.docs ?? [];
                          final totalExercise = weekExercises.fold<int>(0, (sum, doc) => sum + ((doc.data()['calories'] ?? 0) as num).toInt());

                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.fitness_center),
                              title: Text('$totalExercise kcal gastas em exercícios'),
                              subtitle: Text('${weekExercises.length} treino(s) nos últimos 7 dias'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
