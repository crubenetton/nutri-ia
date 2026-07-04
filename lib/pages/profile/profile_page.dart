import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/calculators/health_calculator.dart';
import '../../services/auth_service.dart';
import '../../services/nutri_database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final name = TextEditingController();
  final age = TextEditingController();
  final weight = TextEditingController();
  final height = TextEditingController();
  final goal = TextEditingController();
  final likes = TextEditingController();
  final drinks = TextEditingController();
  final dislikes = TextEditingController();
  final trainingRoutine = TextEditingController();
  final mealsTimes = TextEditingController();

  String sex = 'masculino';
  bool loaded = false;
  bool saving = false;

  void load(Map<String, dynamic> data) {
    if (loaded) return;
    name.text = (data['name'] ?? '').toString();
    age.text = (data['age'] ?? 33).toString();
    weight.text = (data['weightKg'] ?? 83).toString();
    height.text = (data['heightCm'] ?? 169).toString();
    goal.text = (data['goal'] ?? 'Emagrecer e ganhar massa').toString();
    sex = (data['sex'] ?? 'masculino').toString();
    likes.text = (data['likesText'] ?? '').toString();
    drinks.text = (data['drinksText'] ?? '').toString();
    dislikes.text = (data['dislikesText'] ?? '').toString();
    trainingRoutine.text = (data['trainingRoutine'] ?? '').toString();
    mealsTimes.text = (data['mealsTimes'] ?? '').toString();
    loaded = true;
  }

  double get weightKg => double.tryParse(weight.text.replaceAll(',', '.')) ?? 83;
  double get heightCm => double.tryParse(height.text.replaceAll(',', '.')) ?? 169;
  int get userAge => int.tryParse(age.text) ?? 33;

  Future<void> save() async {
    setState(() => saving = true);

    final bmr = HealthCalculator.bmr(sex: sex, weightKg: weightKg, heightCm: heightCm, age: userAge);
    final dailyGoal = HealthCalculator.dailyGoal(bmr: bmr, goal: goal.text);
    final water = HealthCalculator.waterLiters(weightKg: weightKg);
    final protein = HealthCalculator.proteinTarget(weightKg: weightKg);
    final bmi = HealthCalculator.bmi(weightKg: weightKg, heightCm: heightCm);

    await AuthService().updateDisplayName(name.text);

    await NutriDatabase().updateProfileFull(
      name: name.text,
      age: userAge,
      sex: sex,
      weightKg: weightKg,
      heightCm: heightCm,
      goal: goal.text,
      likes: likes.text,
      drinks: drinks.text,
      dislikes: dislikes.text,
      trainingRoutine: trainingRoutine.text,
      mealsTimes: mealsTimes.text,
      bmr: bmr.round(),
      dailyGoalCalories: dailyGoal,
      waterGoalLiters: water,
      proteinGoalGrams: protein,
      bmi: bmi,
    );

    if (!mounted) return;
    setState(() => saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil e metas recalculados no Firebase.')));
  }

  Widget field(String label, TextEditingController controller, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        minLines: lines,
        maxLines: lines == 1 ? 1 : 4,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    final bmr = HealthCalculator.bmr(sex: sex, weightKg: weightKg, heightCm: heightCm, age: userAge);
    final dailyGoal = HealthCalculator.dailyGoal(bmr: bmr, goal: goal.text);
    final water = HealthCalculator.waterLiters(weightKg: weightKg);
    final protein = HealthCalculator.proteinTarget(weightKg: weightKg);
    final bmi = HealthCalculator.bmi(weightKg: weightKg, heightCm: heightCm);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: NutriDatabase().userStream(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() ?? {};
          load(data);

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text('Meu perfil na nuvem', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user?.displayName ?? 'Usuário'),
                  subtitle: Text(user?.email ?? ''),
                ),
              ),
              const SizedBox(height: 12),
              field('Nome', name),
              Row(
                children: [
                  Expanded(child: field('Idade', age)),
                  const SizedBox(width: 12),
                  Expanded(child: field('Peso kg', weight)),
                  const SizedBox(width: 12),
                  Expanded(child: field('Altura cm', height)),
                ],
              ),
              DropdownButtonFormField<String>(
                value: sex,
                decoration: const InputDecoration(labelText: 'Sexo'),
                items: const [
                  DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                  DropdownMenuItem(value: 'feminino', child: Text('Feminino')),
                ],
                onChanged: (value) => setState(() => sex = value ?? sex),
              ),
              const SizedBox(height: 12),
              field('Objetivo', goal),
              field('Horários das refeições', mealsTimes, lines: 2),
              field('Rotina de treino', trainingRoutine, lines: 2),
              field('O que gosta de comer/beber', likes, lines: 3),
              field('Bebidas favoritas', drinks, lines: 2),
              field('O que não gosta', dislikes, lines: 2),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Metas recalculadas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('🔥 Gasto parado: ${bmr.round()} kcal/dia'),
                      Text('🎯 Meta calórica: $dailyGoal kcal/dia'),
                      Text('💧 Água ideal: ${water.toStringAsFixed(1)} L/dia'),
                      Text('🍗 Proteína: $protein g/dia'),
                      Text('⚖ IMC: ${bmi.toStringAsFixed(1)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: saving ? null : save,
                icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                label: const Text('Salvar e recalcular metas'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => AuthService().signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Sair'),
              ),
            ],
          );
        },
      ),
    );
  }
}
