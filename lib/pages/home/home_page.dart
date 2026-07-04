import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/nutri_brain_service.dart';
import '../../services/nutri_database.dart';
import '../../widgets/premium_action_card.dart';
import '../../widgets/premium_progress_card.dart';
import '../ai_photo/ai_photo_page.dart';
import '../coach/coach_page.dart';
import '../exercises/exercises_page.dart';
import '../food/food_page.dart';
import '../progress/body_progress_page.dart';
import '../reports/reports_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  Color heroColor(NutriDaySummary brain) {
    if (brain.availableCalories < 0) return const Color(0xFFDC2626);
    if (brain.availableCalories < 350) return const Color(0xFFF59E0B);
    return const Color(0xFF16A34A);
  }

  String dayStatus(NutriDaySummary brain) {
    if (brain.availableCalories >= 700 && brain.proteinMissing <= 25 && brain.waterMissing <= .7) {
      return 'Excelente ritmo hoje. Continue assim.';
    }
    if (brain.proteinMissing > 35) return 'Priorize proteína nas próximas refeições.';
    if (brain.waterMissing > 1.2) return 'A hidratação está atrasada. Beba água aos poucos.';
    if (brain.availableCalories < 0) return 'Você passou da meta. Amanhã ajustamos sem desespero.';
    return 'Você está no caminho certo hoje.';
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
                final weightDiff = currentWeight - targetWeight;
                final color = heroColor(brain);

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
                      Text('${greeting()}, $name 👋', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text('$goal • gasto parado estimado: $bmr kcal/dia', style: TextStyle(color: Colors.white.withOpacity(.70))),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(34),
                          boxShadow: [BoxShadow(color: color.withOpacity(.22), blurRadius: 24, offset: const Offset(0, 12))],
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(dayStatus(brain), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 10),
                          Text('${brain.availableCalories} kcal', style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 6),
                          const Text('disponíveis hoje', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.65,
                        children: [
                          PremiumActionCard(icon: Icons.restaurant, title: 'Comida', subtitle: 'Registrar refeição', onTap: () => open(context, const FoodPage())),
                          PremiumActionCard(icon: Icons.water_drop, title: '+${waterCupMl}ml', subtitle: 'Adicionar água', onTap: () => NutriDatabase().addWater(waterCupMl)),
                          PremiumActionCard(icon: Icons.camera_alt, title: 'Foto IA', subtitle: 'Modo assistido', onTap: () => open(context, const AIPhotoPage())),
                          PremiumActionCard(icon: Icons.smart_toy, title: 'Coach', subtitle: 'Perguntar agora', onTap: () => open(context, const CoachPage())),
                        ],
                      ),
                      const SizedBox(height: 12),
                      PremiumProgressCard(
                        title: 'Calorias',
                        value: '$consumedCalories / $totalTarget',
                        subtitle: 'Exercício aumenta sua margem do dia.',
                        progress: calorieProgress,
                        icon: Icons.local_fire_department,
                      ),
                      PremiumProgressCard(
                        title: 'Proteína',
                        value: '$consumedProtein / $proteinGoal g',
                        subtitle: brain.proteinMissing > 0 ? 'Faltam ${brain.proteinMissing} g para bater a meta.' : 'Meta de proteína batida.',
                        progress: proteinProgress,
                        icon: Icons.egg_alt,
                      ),
                      PremiumProgressCard(
                        title: 'Água',
                        value: '${waterLiters.toStringAsFixed(1)} / ${waterGoal.toStringAsFixed(1)} L',
                        subtitle: brain.waterMissing > 0 ? 'Faltam ${brain.waterMissing.toStringAsFixed(1)} L hoje.' : 'Meta de água batida.',
                        progress: waterProgress,
                        icon: Icons.water_drop,
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: PremiumActionCard(
                            icon: Icons.fitness_center,
                            title: '$exerciseCalories kcal',
                            subtitle: 'Exercícios hoje',
                            onTap: () => open(context, const ExercisesPage()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PremiumActionCard(
                            icon: Icons.monitor_weight,
                            title: '${currentWeight.toStringAsFixed(1)} kg',
                            subtitle: weightDiff > 0 ? 'faltam ${weightDiff.toStringAsFixed(1)} kg' : 'meta atingida',
                            onTap: () => open(context, const BodyProgressPage()),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('🤖 Coach IA de hoje', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 10),
                            Text(brain.coachMessage),
                            const SizedBox(height: 8),
                            Text('🍽 Jantar: ${brain.dinnerSuggestion()}'),
                            const SizedBox(height: 8),
                            Text('🍕 Pizza: ${brain.pizzaAdvice()}'),
                          ]),
                        ),
                      ),
                      if (meals.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Row(children: [
                          const Expanded(child: Text('Últimas refeições', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
                          TextButton(onPressed: () => open(context, const ReportsPage()), child: const Text('Ver relatório')),
                        ]),
                        const SizedBox(height: 8),
                        for (final meal in meals.take(4))
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
