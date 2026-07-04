import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/nutri_ai_service.dart';
import '../../services/nutri_brain_service.dart';
import '../../services/nutri_database.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  final message = TextEditingController();
  NutriAIAnswer? answer;
  bool saving = false;

  Future<void> saveEstimatedMeal() async {
    final current = answer;
    if (current == null || !current.canRegisterMeal) return;

    setState(() => saving = true);
    try {
      await NutriDatabase().addMeal(
        name: current.title,
        calories: current.estimatedCalories ?? 0,
        protein: current.estimatedProtein ?? 0,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refeição registrada pelo Coach IA.')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void ask(NutriAIContext context) {
    setState(() {
      answer = NutriAIService.ask(question: message.text, context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: NutriDatabase().userStream(),
      builder: (context, userSnapshot) {
        final data = userSnapshot.data?.data() ?? {};
        final name = (data['name'] ?? 'Lucas').toString();
        final goal = (data['goal'] ?? '').toString();
        final likes = (data['likesText'] ?? '').toString();
        final dislikes = (data['dislikesText'] ?? '').toString();
        final drinks = (data['drinksText'] ?? '').toString();
        final trainingRoutine = (data['trainingRoutine'] ?? '').toString();
        final dailyGoal = ((data['dailyGoalCalories'] ?? 2200) as num).toInt();
        final waterGoal = ((data['waterGoalLiters'] ?? 2.9) as num).toDouble();
        final proteinGoal = ((data['proteinGoalGrams'] ?? 132) as num).toInt();
        final waterMl = ((data['waterMlToday'] ?? 0) as num).toInt();

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: NutriDatabase().mealsTodayStream(),
          builder: (context, mealsSnapshot) {
            final meals = mealsSnapshot.data?.docs ?? [];
            final consumed = meals.fold<int>(0, (sum, doc) => sum + ((doc.data()['calories'] ?? 0) as num).toInt());
            final protein = meals.fold<int>(0, (sum, doc) => sum + ((doc.data()['protein'] ?? 0) as num).toInt());

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: NutriDatabase().exercisesTodayStream(),
              builder: (context, exercisesSnapshot) {
                final exercises = exercisesSnapshot.data?.docs ?? [];
                final exercise = exercises.fold<int>(0, (sum, doc) => sum + ((doc.data()['calories'] ?? 0) as num).toInt());

                final day = NutriDaySummary(
                  consumedCalories: consumed,
                  exerciseCalories: exercise,
                  targetCalories: dailyGoal,
                  proteinConsumed: protein,
                  proteinTarget: proteinGoal,
                  waterConsumedLiters: waterMl / 1000,
                  waterTargetLiters: waterGoal,
                );

                final aiContext = NutriAIContext(
                  name: name,
                  goal: goal,
                  likes: likes,
                  dislikes: dislikes,
                  drinks: drinks,
                  trainingRoutine: trainingRoutine,
                  day: day,
                );

                return Scaffold(
                  appBar: AppBar(title: const Text('Coach IA')),
                  body: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      const Text('Coach IA personalizado', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      Text(
                        'Pergunte sobre comida, registre uma refeição ou peça sugestão. O Coach usa seu Firebase e suas metas.',
                        style: TextStyle(color: Colors.white.withOpacity(.75)),
                      ),
                      const SizedBox(height: 14),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text('Hoje: ${day.availableCalories} kcal disponíveis • faltam ${day.proteinMissing} g proteína • faltam ${day.waterMissing.toStringAsFixed(1)} L água.'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: message,
                        minLines: 4,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: 'Ex: posso comer pizza hoje? / comi 2 ovos e café com leite',
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => ask(aiContext),
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Perguntar ao Coach IA'),
                      ),
                      if (answer != null) ...[
                        const SizedBox(height: 14),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(answer!.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(answer!.message),
                                if (answer!.estimatedCalories != null) ...[
                                  const SizedBox(height: 10),
                                  Text('🔥 ${answer!.estimatedCalories} kcal'),
                                  Text('🍗 ${answer!.estimatedProtein} g proteína'),
                                ],
                                if (answer!.canRegisterMeal) ...[
                                  const SizedBox(height: 12),
                                  FilledButton.icon(
                                    onPressed: saving ? null : saveEstimatedMeal,
                                    icon: saving
                                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                        : const Icon(Icons.check),
                                    label: const Text('Registrar no diário'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
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
