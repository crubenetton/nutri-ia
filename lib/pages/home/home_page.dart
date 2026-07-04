import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/nutri_brain_service.dart';
import '../../services/nutri_database.dart';
import '../ai_photo/ai_photo_page.dart';
import '../coach/coach_page.dart';
import '../exercises/exercises_page.dart';
import '../food/food_page.dart';
import '../reports/reports_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget progressBlock({
    required String title,
    required String value,
    required double progress,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 22),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress.clamp(0, 1), minHeight: 12, borderRadius: BorderRadius.circular(20)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: NutriDatabase().userStream(),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data?.data() ?? {};
        final name = (user['name'] ?? 'Lucas').toString();
        final dailyGoal = ((user['dailyGoalCalories'] ?? 2200) as num).toInt();
        final waterGoal = ((user['waterGoalLiters'] ?? 2.9) as num).toDouble();
        final proteinGoal = ((user['proteinGoalGrams'] ?? 132) as num).toInt();
        final waterMl = ((user['waterMlToday'] ?? 0) as num).toInt();
        final waterCupMl = ((user['waterCupMl'] ?? 250) as num).toInt();
        final bmr = ((user['bmr'] ?? 1726) as num).toInt();
        final currentWeight = ((user['weightKg'] ?? 83) as num).toDouble();
        final targetWeight = ((user['targetWeightKg'] ?? 78) as num).toDouble();
        final goal = (user['goal'] ?? 'Emagrecer e ganhar massa').toString();
        final waterLiters = waterMl / 1000;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: NutriDatabase().mealsTodayStream(),
          builder: (context, mealsSnapshot) {
            final meals = mealsSnapshot.data?.docs ?? [];
            final consumedCalories = meals.fold<int>(0, (sum, doc) => sum + ((doc.data()['calories'] ?? 0) as num).toInt());
            final consumedProtein = meals.fold<int>(0, (sum, doc) => sum + ((doc.data()['protein'] ?? 0) as num).toInt());

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: NutriDatabase().exercisesTodayStream(),
              builder: (context, exercisesSnapshot) {
                final exercises = exercisesSnapshot.data?.docs ?? [];
                final exerciseCalories = exercises.fold<int>(0, (sum, doc) => sum + ((doc.data()['calories'] ?? 0) as num).toInt());

                final brain = NutriDaySummary(
                  consumedCalories: consumedCalories,
                  exerciseCalories: exerciseCalories,
                  targetCalories: dailyGoal,
                  proteinConsumed: consumedProtein,
                  proteinTarget: proteinGoal,
                  waterConsumedLiters: waterLiters,
                  waterTargetLiters: waterGoal,
                );

                final totalTarget = dailyGoal + exerciseCalories;
                final calorieProgress = consumedCalories / totalTarget.clamp(1, 99999);
                final proteinProgress = consumedProtein / proteinGoal.clamp(1, 99999);
                final waterProgress = waterLiters / waterGoal.clamp(0.1, 99);
                final available = brain.availableCalories;
                final cardColor = available >= 500 ? const Color(0xFF16A34A) : available >= 0 ? const Color(0xFFF59E0B) : const Color(0xFFDC2626);
                final weightDiff = currentWeight - targetWeight;

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Nutri IA'),
                    leading: Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  ),
                  body: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      Text('Olá, $name 👋', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text('$goal • gasto parado $bmr kcal/dia', style: TextStyle(color: Colors.white.withOpacity(.72))),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(32)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Calorias disponíveis hoje', style: TextStyle(color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('$available kcal', style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Text(brain.status, style: const TextStyle(color: Colors.white)),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Ações rápidas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Wrap(spacing: 10, runSpacing: 10, children: [
                              FilledButton.icon(onPressed: () => open(context, const FoodPage()), icon: const Icon(Icons.restaurant), label: const Text('Comida')),
                              FilledButton.icon(onPressed: () => NutriDatabase().addWater(waterCupMl), icon: const Icon(Icons.water_drop), label: Text('+${waterCupMl}ml')),
                              FilledButton.icon(onPressed: () => open(context, const AIPhotoPage()), icon: const Icon(Icons.camera_alt), label: const Text('Foto IA')),
                              FilledButton.icon(onPressed: () => open(context, const CoachPage()), icon: const Icon(Icons.smart_toy), label: const Text('Coach')),
                              OutlinedButton.icon(onPressed: () => open(context, const ExercisesPage()), icon: const Icon(Icons.fitness_center), label: const Text('Exercício')),
                              OutlinedButton.icon(onPressed: () => open(context, const ReportsPage()), icon: const Icon(Icons.bar_chart), label: const Text('Relatório')),
                            ]),
                          ]),
                        ),
                      ),
                      progressBlock(title: 'Calorias', value: '$consumedCalories / $totalTarget kcal', progress: calorieProgress, icon: Icons.local_fire_department),
                      progressBlock(title: 'Proteína', value: '$consumedProtein / $proteinGoal g', progress: proteinProgress, icon: Icons.egg_alt),
                      progressBlock(title: 'Água', value: '${waterLiters.toStringAsFixed(1)} / ${waterGoal.toStringAsFixed(1)} L', progress: waterProgress, icon: Icons.water_drop),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: Card(child: ListTile(leading: const Icon(Icons.fitness_center), title: const Text('Exercício'), subtitle: Text('$exerciseCalories kcal gastas')))),
                        const SizedBox(width: 10),
                        Expanded(child: Card(child: ListTile(leading: const Icon(Icons.restaurant), title: const Text('Refeições'), subtitle: Text('${meals.length} registro(s)')))),
                      ]),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('🤖 Coach IA de hoje', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Text(brain.coachMessage),
                            const SizedBox(height: 8),
                            Text('🍽 Jantar: ${brain.dinnerSuggestion()}'),
                            const SizedBox(height: 8),
                            Text('🍕 Pizza: ${brain.pizzaAdvice()}'),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.monitor_weight),
                          title: Text('Peso: ${currentWeight.toStringAsFixed(1)} kg'),
                          subtitle: Text(weightDiff > 0 ? 'Faltam ${weightDiff.toStringAsFixed(1)} kg para ${targetWeight.toStringAsFixed(1)} kg.' : 'Você está na meta ou abaixo dela.'),
                          trailing: const Icon(Icons.trending_down),
                        ),
                      ),
                      if (meals.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Text('Últimas refeições', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        for (final meal in meals.take(3))
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.restaurant_menu),
                              title: Text(meal.data()['name'] ?? 'Refeição'),
                              subtitle: Text('${meal.data()['calories'] ?? 0} kcal • ${meal.data()['protein'] ?? 0} g proteína'),
                            ),
                          ),
                      ],
                      const SizedBox(height: 18),
                      const Text('Powered by Cru Benetton®', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
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
