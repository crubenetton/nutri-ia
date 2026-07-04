import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/food_ai_estimator.dart';
import '../../services/nutri_database.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final aiText = TextEditingController();
  final name = TextEditingController();
  final calories = TextEditingController();
  final protein = TextEditingController();
  final carbs = TextEditingController();
  final fat = TextEditingController();

  FoodAIResult? result;
  double portion = 1.0;
  bool loading = false;

  int adjusted(int value) => (value * portion).round();

  void estimateByText() {
    final text = aiText.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o que você comeu ou bebeu.')),
      );
      return;
    }

    final estimated = FoodAIEstimator.estimate(text);

    setState(() {
      result = estimated;
      portion = 1.0;
      name.text = estimated.title;
      calories.text = estimated.calories.toString();
      protein.text = estimated.protein.toString();
      carbs.text = estimated.carbs.toString();
      fat.text = estimated.fat.toString();
    });
  }

  void applyPortion() {
    final r = result;
    if (r == null) return;

    setState(() {
      calories.text = adjusted(r.calories).toString();
      protein.text = adjusted(r.protein).toString();
      carbs.text = adjusted(r.carbs).toString();
      fat.text = adjusted(r.fat).toString();
    });
  }

  String coachAfterMeal(int kcal, int prot) {
    if (prot >= 35) {
      return 'Excelente refeição! Boa quantidade de proteína. Isso ajuda muito no ganho de massa e saciedade.';
    }
    if (prot >= 15) {
      return 'Boa refeição. Ainda vale reforçar proteína nas próximas refeições.';
    }
    if (kcal > 600 && prot < 15) {
      return 'Essa refeição teve bastante caloria e pouca proteína. Na próxima, tente incluir frango, ovos, carne, iogurte ou whey.';
    }
    return 'Refeição registrada. Continue acompanhando para bater suas metas do dia.';
  }

  Future<void> addMeal() async {
    final kcal = int.tryParse(calories.text) ?? 0;
    final prot = int.tryParse(protein.text) ?? 0;

    if (name.text.trim().isEmpty || kcal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha pelo menos nome e calorias.')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      await NutriDatabase().addMeal(
        name: name.text.trim(),
        calories: kcal,
        protein: prot,
      );

      final coach = coachAfterMeal(kcal, prot);

      aiText.clear();
      name.clear();
      calories.clear();
      protein.clear();
      carbs.clear();
      fat.clear();

      setState(() {
        result = null;
        portion = 1.0;
      });

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Refeição salva ✅'),
          content: Text(coach),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> quickSave(String title, int kcal, int prot) async {
    await NutriDatabase().addMeal(name: title, calories: kcal, protein: prot);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title salvo. Dashboard atualizado.')),
    );
  }

  Future<void> deleteMeal(String id) async {
    await NutriDatabase().deleteMeal(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refeição apagada.')),
    );
  }

  Widget quick(String title, int kcal, int prot) {
    return ActionChip(
      label: Text(title),
      onPressed: () => quickSave(title, kcal, prot),
    );
  }

  Widget itemRow(FoodItemEstimate item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text('${adjusted(item.calories)} kcal'),
          const SizedBox(width: 10),
          Text('${adjusted(item.protein)}g prot'),
        ],
      ),
    );
  }

  Widget summaryCard(int totalKcal, int totalProtein, int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16A34A),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Resumo de hoje', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text('$totalKcal kcal', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 6),
        Text('$totalProtein g de proteína • $count refeição(ões)', style: const TextStyle(color: Colors.white)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = result;

    return Scaffold(
      appBar: AppBar(title: const Text('Diário Inteligente')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Registrar refeição', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            'Escreva como você falaria. O Nutri IA estima e deixa você ajustar antes de salvar.',
            style: TextStyle(color: Colors.white.withOpacity(.72)),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: aiText,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'O que você comeu ou bebeu?',
              hintText: 'Ex: café com leite, 2 ovos e pão com manteiga',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: estimateByText,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Analisar refeição'),
          ),

          const SizedBox(height: 16),
          const Text('Salvar rápido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              quick('Pão + 2 ovos', 350, 20),
              quick('Arroz + frango', 520, 42),
              quick('Whey com leite', 240, 28),
              quick('Banana', 90, 1),
              quick('Hambúrguer', 700, 35),
              quick('Pizza 2 fatias', 620, 24),
            ],
          ),

          if (r != null) ...[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Resultado detalhado', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  for (final item in r.items) itemRow(item),
                  const SizedBox(height: 12),
                  Text('Quantidade: ${(portion * 100).round()}%'),
                  Slider(
                    value: portion,
                    min: 0.25,
                    max: 2.0,
                    divisions: 7,
                    label: '${(portion * 100).round()}%',
                    onChanged: (value) {
                      setState(() => portion = value);
                      applyPortion();
                    },
                  ),
                  const Divider(),
                  Text('🔥 Total: ${adjusted(r.calories)} kcal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('🍗 Proteína: ${adjusted(r.protein)} g'),
                  Text('🍞 Carboidratos: ${adjusted(r.carbs)} g'),
                  Text('🥑 Gorduras: ${adjusted(r.fat)} g'),
                  const SizedBox(height: 8),
                  Text(r.explanation, style: TextStyle(color: Colors.white.withOpacity(.65))),
                ]),
              ),
            ),
          ],

          const SizedBox(height: 18),
          const Text('Ajuste antes de salvar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome da refeição')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: calories, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calorias'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: protein, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Proteína'))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: carbs, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Carboidratos'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: fat, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Gorduras'))),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: loading ? null : addMeal,
            icon: loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check),
            label: const Text('Salvar no diário'),
          ),

          const SizedBox(height: 24),
          const Text('Refeições de hoje', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: NutriDatabase().mealsTodayStream(),
            builder: (context, snapshot) {
              final meals = snapshot.data?.docs ?? [];

              if (snapshot.hasError) {
                return Card(
                  child: ListTile(
                    title: const Text('Erro ao carregar refeições'),
                    subtitle: Text('${snapshot.error}'),
                  ),
                );
              }

              if (meals.isEmpty) {
                return const Card(child: ListTile(title: Text('Nenhuma refeição registrada hoje.')));
              }

              final totalKcal = meals.fold<int>(0, (sum, meal) => sum + ((meal.data()['calories'] ?? 0) as num).toInt());
              final totalProtein = meals.fold<int>(0, (sum, meal) => sum + ((meal.data()['protein'] ?? 0) as num).toInt());

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  summaryCard(totalKcal, totalProtein, meals.length),
                  const SizedBox(height: 10),
                  for (final meal in meals)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.restaurant),
                        title: Text(meal.data()['name'] ?? 'Refeição'),
                        subtitle: Text('${meal.data()['calories'] ?? 0} kcal • ${meal.data()['protein'] ?? 0} g proteína'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => deleteMeal(meal.id),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
