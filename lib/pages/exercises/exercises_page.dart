import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/nutri_database.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final name = TextEditingController();
  final minutes = TextEditingController();
  final calories = TextEditingController();
  bool loading = false;

  Future<void> saveExercise() async {
    setState(() => loading = true);
    try {
      await NutriDatabase().addExercise(
        name: name.text.trim().isEmpty ? 'Exercício' : name.text,
        calories: int.tryParse(calories.text) ?? 0,
        minutes: int.tryParse(minutes.text) ?? 0,
      );

      name.clear();
      minutes.clear();
      calories.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exercício salvo.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> quick(String title, int min, int kcal) async {
    await NutriDatabase().addExercise(name: title, calories: kcal, minutes: min);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title salvo.')));
  }

  Future<void> deleteExercise(String id) async {
    await NutriDatabase().deleteExercise(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exercício apagado.')));
  }

  Widget quickChip(String title, int min, int kcal) {
    return ActionChip(
      label: Text(title),
      onPressed: () => quick(title, min, kcal),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercícios'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Registrar exercício', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Use atalhos ou registre manualmente.', style: TextStyle(color: Colors.white.withOpacity(.75))),
          const SizedBox(height: 16),

          const Text('Atalhos rápidos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              quickChip('Academia 60 min', 60, 300),
              quickChip('Esteira 5 km', 50, 392),
              quickChip('Caminhada 30 min', 30, 160),
              quickChip('Corrida 30 min', 30, 330),
              quickChip('Bike 40 min', 40, 280),
              quickChip('Futebol 60 min', 60, 550),
            ],
          ),

          const SizedBox(height: 22),
          const Text('Manual', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome do exercício')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: minutes, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Minutos'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: calories, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kcal gastas'))),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: loading ? null : saveExercise,
            icon: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
            label: const Text('Salvar exercício'),
          ),

          const SizedBox(height: 24),
          const Text('Hoje', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: NutriDatabase().exercisesTodayStream(),
            builder: (context, snapshot) {
              final items = snapshot.data?.docs ?? [];
              if (items.isEmpty) {
                return const Card(child: ListTile(title: Text('Nenhum exercício registrado hoje.')));
              }

              final total = items.fold<int>(0, (sum, doc) => sum + ((doc.data()['calories'] ?? 0) as num).toInt());

              return Column(
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_fire_department),
                      title: Text('$total kcal gastas hoje'),
                      subtitle: Text('${items.length} exercício(s) registrado(s)'),
                    ),
                  ),
                  for (final item in items)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.fitness_center),
                        title: Text((item.data()['name'] ?? 'Exercício').toString()),
                        subtitle: Text('${item.data()['minutes'] ?? 0} min • ${item.data()['calories'] ?? 0} kcal'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => deleteExercise(item.id),
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
