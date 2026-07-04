import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/nutri_database.dart';

class WeeklyPlanPage extends StatelessWidget {
  const WeeklyPlanPage({super.key});

  List<String> _foods(String text) {
    final items = text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (items.isEmpty) return ['pão', 'ovos', 'arroz', 'frango', 'carne', 'batata doce', 'banana', 'whey', 'iogurte'];
    return items;
  }

  String pick(List<String> foods, List<String> options) {
    for (final option in options) {
      for (final food in foods) {
        if (food.toLowerCase().contains(option.toLowerCase()) || option.toLowerCase().contains(food.toLowerCase())) return food;
      }
    }
    return options.first;
  }

  Widget dayCard(String day, List<String> foods, bool freeNight) {
    final breakfastProtein = pick(foods, ['ovos', 'whey', 'iogurte']);
    final carb = pick(foods, ['pão', 'arroz', 'batata doce', 'banana']);
    final lunchProtein = pick(foods, ['frango', 'carne', 'ovos']);
    final snack = pick(foods, ['whey', 'iogurte', 'banana', 'pão']);
    final dinner = freeNight ? 'refeição livre controlada' : '$lunchProtein + $carb';
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(day, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text('09h Café: $carb + $breakfastProtein'),
      Text('11h Almoço: $lunchProtein + $carb'),
      Text('15h Lanche: $snack'),
      Text('Noite: $dinner'),
      const SizedBox(height: 8),
      Text(freeNight ? '🍕 Livre controlado: encaixe pizza/lanche sem exagerar.' : '💧 Beba água aos poucos e bata proteína.', style: const TextStyle(color: Colors.white70)),
    ])));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: NutriDatabase().userStream(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};
        final foods = _foods((data['likesText'] ?? '').toString());
        final freeWeekend = (data['freeWeekendNight'] ?? true) == true;
        return Scaffold(
          appBar: AppBar(title: const Text('Plano semanal')),
          body: ListView(padding: const EdgeInsets.all(18), children: [
            const Text('Cardápio automático', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Montado com base nos alimentos que você cadastrou.', style: TextStyle(color: Colors.white.withOpacity(.75))),
            const SizedBox(height: 16),
            dayCard('Segunda', foods, false), dayCard('Terça', foods, false), dayCard('Quarta', foods, false), dayCard('Quinta', foods, false), dayCard('Sexta', foods, false), dayCard('Sábado', foods, freeWeekend), dayCard('Domingo', foods, freeWeekend),
          ]),
        );
      },
    );
  }
}
